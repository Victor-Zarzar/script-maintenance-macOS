import os
import subprocess
import shutil

def run_command(command, use_sudo=False):
    try:
        if use_sudo:
            command = f"sudo {command}"
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar: {command}\n{e}")

def update_system():
    print("🔄 Atualizando o sistema e Homebrew...")
    run_command("softwareupdate -i -a")
    run_command("brew update && brew upgrade")
    run_command("brew cleanup") 
    run_command("brew doctor") 

def clean_caches():
    print("🧹 Limpando caches do sistema...")
    user_cache = os.path.expanduser("~/Library/Caches")
    system_cache = "/Library/Caches"

    if os.path.exists(user_cache):
        for item in os.listdir(user_cache):
            item_path = os.path.join(user_cache, item)
            try:
                if os.path.isdir(item_path):
                    shutil.rmtree(item_path, ignore_errors=True)
                else:
                    os.remove(item_path)
            except PermissionError:
                print(f"Permissão negada para limpar: {item_path}")

    if os.path.exists(system_cache):
        run_command(f"rm -rf {system_cache}/*", use_sudo=True)

def clean_logs():
    print("🗂 Limpando logs antigos...")
    user_logs = os.path.expanduser("~/Library/Logs")
    system_logs = "/var/log"

    if os.path.exists(user_logs):
        shutil.rmtree(user_logs, ignore_errors=True)

    if os.path.exists(system_logs):
        run_command(f"rm -rf {system_logs}/*", use_sudo=True)

def check_docker():
    print("🐳 Limpando imagens, containers e volumes não usados do Docker...")
    try:
        run_command("docker system info")
        run_command("docker system prune -af --volumes")
    except Exception as e:
        print("Erro ao verificar ou limpar Docker. Verifique se o Docker está em execução.")

if __name__ == "__main__":
    print("Iniciando manutenção do macOS...")
    update_system()
    clean_caches()
    clean_logs()
    check_docker()
    print("✅ Manutenção do macOS concluída!")
