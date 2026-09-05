import re, subprocess
from pathlib import Path

# Obtém o diretório onde o script está
script_dir = Path(__file__).parent.absolute()
readme_path = script_dir / "README.md"

# Gera a árvore a partir do diretório atual (relativo)
tree = subprocess.check_output(
    ["tree", "-a", "--dirsfirst", "--noreport", "-I", ".git", "."],
    cwd=script_dir,  # IMPORTANTE: executa o tree dentro do diretório do script
    text=True
)

block = f"<!-- TREE_START -->\n```\n{tree}```\n<!-- TREE_END -->"
readme = open(readme_path).read()
updated = re.sub(r"<!-- TREE_START -->.*?<!-- TREE_END -->", block, readme, flags=re.DOTALL)
open(readme_path, "w").write(updated)
