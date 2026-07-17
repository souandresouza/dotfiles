#!/usr/bin/env python3
import gi
gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib
from gi.repository.Playerctl import Player
import argparse
import logging
import sys
import signal
import gi
import json
import os
from typing import List

logger = logging.getLogger(__name__)

def signal_handler(sig, frame):
    logger.info("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    sys.exit(0)

class PlayerManager:
    def __init__(self, selected_player=None, excluded_player=[]):
        self.manager = Playerctl.PlayerManager()
        self.loop = GLib.MainLoop()
        self.manager.connect(
            "name-appeared", lambda *args: self.on_player_appeared(*args))
        self.manager.connect(
            "player-vanished", lambda *args: self.on_player_vanished(*args))

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
        self.selected_player = selected_player
        self.excluded_player = excluded_player.split(',') if excluded_player else []

        self.init_players()

    def init_players(self):
        for player in self.manager.props.player_names:
            if player.name in self.excluded_player:
                continue
            if self.selected_player is not None and self.selected_player != player.name:
                logger.debug(f"{player.name} is not the filtered player, skipping it")
                continue
            self.init_player(player)

    def run(self):
        logger.info("Starting main loop")
        self.loop.run()

    def init_player(self, player):
        logger.info(f"Initialize new player: {player.name}")
        player = Playerctl.Player.new_from_name(player)
        player.connect("playback-status",
                       self.on_playback_status_changed, None)
        player.connect("metadata", self.on_metadata_changed, None)
        self.manager.manage_player(player)
        self.on_metadata_changed(player, player.props.metadata)

    def get_players(self) -> List[Player]:
        return self.manager.props.players

    def write_output(self, text, player):
        logger.debug(f"Writing output: {text}")

        if len(text) > 40:
            text = text[:40]

        text = text.replace("&", "&amp;")

        output = {"text": text,
                  "class": "custom-" + player.props.player_name,
                  "alt": player.props.player_name,
                  "tooltip": f"{player.props.player_name}: {text}"}
        
        sys.stdout.write(json.dumps(output) + "\n")
        sys.stdout.flush()

    def clear_output(self):
        sys.stdout.write("\n")
        sys.stdout.flush()

    def on_playback_status_changed(self, player, status, _=None):
        logger.debug(f"Playback status changed for player {player.props.player_name}: {status}")
        self.on_metadata_changed(player, player.props.metadata)

    def get_first_playing_player(self):
        players = self.get_players()
        logger.debug(f"Getting first playing player from {len(players)} players")
        
        if len(players) > 0:
            # Remove players que estão "Stopped"
            active_players = [p for p in players if p.props.status != "Stopped"]
            
            if len(active_players) > 0:
                # Prioridade 1: qualquer um tocando
                for player in active_players[::-1]:
                    if player.props.status == "Playing":
                        return player
                
                # Prioridade 2: qualquer um pausado
                for player in active_players[::-1]:
                    if player.props.status == "Paused":
                        return player
                
                # Prioridade 3: qualquer um ativo (não stopped)
                return active_players[0]
            else:
                logger.debug("No active players found")
                return None
        else:
            logger.debug("No players found")
            return None

    def show_most_important_player(self):
        logger.debug("Showing most important player")
        current_player = self.get_first_playing_player()
        if current_player is not None:
            self.on_metadata_changed(current_player, current_player.props.metadata)
        else:    
            self.clear_output()
            output = {"text": " 404 - Not Found",
                      "class": "custom-spotify",
                      "alt": "spotify",
                      "tooltip": "Nenhum player ativo"}
            
            sys.stdout.write(json.dumps(output) + "\n")
            sys.stdout.flush()

    def on_metadata_changed(self, player, metadata, _=None):
        logger.debug(f"Metadata changed for player {player.props.player_name}")
        
        # Ignora players com status "Stopped"
        if player.props.status == "Stopped":
            logger.debug(f"Player {player.props.player_name} is stopped, ignoring")
            return
            
        player_name = player.props.player_name
        artist = player.get_artist()
        title = player.get_title()
        title = title.replace("&", "&amp;")

        if player_name == "spotify" and "mpris:trackid" in metadata.keys() and ":ad:" in player.props.metadata["mpris:trackid"]:
            track_info = "Advertisement"
        elif artist is not None and title is not None:
            track_info = f"{artist} - {title}"
        else:
            track_info = title

        if track_info:
            if player.props.status == "Playing":
                track_info = " " + track_info
            else:
                track_info = " " + track_info
                
        # Só mostra se for o player mais importante
        current_playing = self.get_first_playing_player()
        if current_playing is None or current_playing.props.player_name == player.props.player_name:
            self.write_output(track_info, player)
        else:
            logger.debug(f"Other player {current_playing.props.player_name} is playing, skipping")

    def on_player_appeared(self, _, player):
        logger.info(f"Player has appeared: {player.name}")
        if player.name in self.excluded_player:
            logger.debug("New player appeared, but it's in exclude player list, skipping")
            return
        if player is not None and (self.selected_player is None or player.name == self.selected_player):
            self.init_player(player)
        else:
            logger.debug("New player appeared, but it's not the selected player, skipping")

    def on_player_vanished(self, _, player):
        logger.info(f"Player {player.props.player_name} has vanished")
        self.show_most_important_player()

def parse_arguments():
    parser = argparse.ArgumentParser()

    parser.add_argument("-v", "--verbose", action="count", default=0)
    parser.add_argument("-x", "--exclude", help="Comma-separated list of excluded player")
    parser.add_argument("--player", help="Filter for specific player")
    parser.add_argument("--enable-logging", action="store_true")
    
    # Argumentos para controle
    parser.add_argument("--control", choices=["play-pause", "next", "previous", "stop", "volume-up", "volume-down"])
    parser.add_argument("--control-player", help="Player name for control commands")

    return parser.parse_args()

def control_player(command, player_name=None):
    """Executa comandos de controle em um player"""
    try:
        # Conecta ao manager para listar players
        manager = Playerctl.PlayerManager()
        
        if player_name:
            # Tenta usar o player específico
            try:
                player = Playerctl.Player.new_from_name(player_name)
                execute_command(player, command)
                return
            except:
                print(f"Player '{player_name}' not found")
                sys.exit(1)
        else:
            # Pega o primeiro player ativo
            players = manager.props.players
            if not players:
                print("No players found")
                sys.exit(1)
            
            # Prioriza players tocando
            for p in players:
                if p.props.status == "Playing":
                    execute_command(p, command)
                    return
            
            # Se nenhum estiver tocando, usa o primeiro
            execute_command(players[0], command)
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def execute_command(player, command):
    """Executa um comando específico no player"""
    commands = {
        "play-pause": player.play_pause,
        "next": player.next,
        "previous": player.previous,
        "stop": player.stop,
    }
    
    if command in commands:
        commands[command]()
    elif command == "volume-up":
        current_volume = player.props.volume
        player.set_volume(min(1.0, current_volume + 0.1))
    elif command == "volume-down":
        current_volume = player.props.volume
        player.set_volume(max(0.0, current_volume - 0.1))
    else:
        print(f"Unknown command: {command}")

def main():
    arguments = parse_arguments()
    
    # Se for um comando de controle, executa e sai
    if arguments.control:
        control_player(arguments.control, arguments.control_player)
        return

    # Caso contrário, modo de exibição normal
    output = {"text": " 404 - Not Found",
              "class": "custom-spotify",
              "alt": "spotify",
              "tooltip": "Nenhum player ativo"}

    sys.stdout.write(json.dumps(output) + "\n")
    sys.stdout.flush()

    if arguments.enable_logging:
        logfile = os.path.join(os.path.dirname(
            os.path.realpath(__file__)), "media-player.log")
        logging.basicConfig(filename=logfile, level=logging.DEBUG,
                            format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s")

    logger.setLevel(max((3 - arguments.verbose) * 10, 0))

    logger.info("Creating player manager")
    if arguments.player:
        logger.info(f"Filtering for player: {arguments.player}")
    if arguments.exclude:
        logger.info(f"Exclude player {arguments.exclude}")

    player = PlayerManager(arguments.player, arguments.exclude)
    player.run()

if __name__ == "__main__":
    main()