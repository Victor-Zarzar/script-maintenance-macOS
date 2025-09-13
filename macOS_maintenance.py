import os
import subprocess
import shutil
from pathlib import Path

def run_command(command, use_sudo=False, ignore_errors=False):
    """Executa comando com tratamento de erro melhorado"""
    try:
        if use_sudo:
            command = f"sudo {command}"
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        return True, result.stdout
    except subprocess.CalledProcessError as e:
        if not ignore_errors:
            print(f"⚠️ Erro ao executar: {command}\n{e}")
        return False, e.stderr
    except Exception as e:
        if not ignore_errors:
            print(f"⚠️ Erro inesperado: {e}")
        return False, str(e)

def update_system():
    """Atualiza sistema e Homebrew"""
    print("🔄 Atualizando o sistema e Homebrew...")
    
    print("  📱 Verificando atualizações do macOS...")
    run_command("softwareupdate -l")
    run_command("softwareupdate -i -a", ignore_errors=True)
    
    success, _ = run_command("which brew", ignore_errors=True)
    if success:
        print("  🍺 Atualizando Homebrew...")
        run_command("brew update")
        run_command("brew upgrade")
        run_command("brew cleanup")
        run_command("brew autoremove")
        run_command("brew doctor", ignore_errors=True)
    else:
        print("  ℹ️ Homebrew não encontrado, pulando...")

def clean_software_update_cache():
    """Limpa cache de atualizações de software - NOVA FUNCIONALIDADE"""
    print("🔄 Limpando cache de atualizações de software...")
    
    software_update_paths = [
        "/Library/Updates",
        "/System/Library/CoreServices/Software Update.app/Contents/Resources/SUUpdatesCatalog.gz",
        "/var/folders/*/C/com.apple.SoftwareUpdate",
        "~/Library/Caches/com.apple.SoftwareUpdate",
        "/Library/Caches/com.apple.SoftwareUpdate"
    ]
    
    for path in software_update_paths:
        expanded_path = os.path.expanduser(path)
        if "*" in expanded_path:
            run_command(f"rm -rf {expanded_path}", use_sudo=True, ignore_errors=True)
        elif os.path.exists(expanded_path):
            try:
                if os.path.isdir(expanded_path):
                    shutil.rmtree(expanded_path, ignore_errors=True)
                else:
                    os.remove(expanded_path)
                print(f"  ✅ Removido: {expanded_path}")
            except PermissionError:
                run_command(f"rm -rf '{expanded_path}'", use_sudo=True, ignore_errors=True)

def clean_xcode_build_cache():
    """Limpa cache de builds do Xcode"""
    print("🔨 Limpando cache de builds do Xcode...")
    
    xcode_paths = [
        "~/Library/Developer/Xcode/DerivedData",
        "~/Library/Caches/com.apple.dt.Xcode",
        "~/Library/Developer/Xcode/Archives",
        "~/Library/Developer/CoreSimulator/Caches",
        "~/Library/Caches/com.apple.dt.XCPGDeviceSupport",
        "/Library/Caches/com.apple.dt.Xcode"
    ]
    
    for path in xcode_paths:
        expanded_path = os.path.expanduser(path)
        if os.path.exists(expanded_path):
            try:
                if os.path.isdir(expanded_path):
                    size = get_folder_size(expanded_path)
                    shutil.rmtree(expanded_path, ignore_errors=True)
                    print(f"  ✅ Removido {format_bytes(size)}: {path}")
                else:
                    os.remove(expanded_path)
            except PermissionError:
                run_command(f"rm -rf '{expanded_path}'", use_sudo=True, ignore_errors=True)

def clean_ios_simulator_cache():
    """Limpa cache do simulador iOS"""
    print("📱 Limpando cache do Simulador iOS...")
    
    simulator_paths = [
        "~/Library/Developer/CoreSimulator/Devices",
        "~/Library/Logs/CoreSimulator"
    ]
    
    run_command("xcrun simctl delete unavailable", ignore_errors=True)
    run_command("xcrun simctl erase all", ignore_errors=True)
    
    for path in simulator_paths:
        expanded_path = os.path.expanduser(path)
        if os.path.exists(expanded_path):
            try:
                size = get_folder_size(expanded_path)
                shutil.rmtree(expanded_path, ignore_errors=True)
                print(f"  ✅ Removido {format_bytes(size)}: {path}")
            except Exception as e:
                print(f"  ⚠️ Erro ao remover {path}: {e}")

def clean_caches():
    """Limpa caches do sistema"""
    print("🧹 Limpando caches do sistema...")
    
    cache_paths = [
    
        "~/Library/Caches",
        "~/Library/Application Support/CrashReporter",
        "~/Library/Logs",
        "~/Library/Saved Application State",
        "/Library/Caches",
        "/System/Library/Caches",
        "/var/folders/*/*/C/*",
        "~/Library/Caches/com.apple.akd",
        "~/Library/Caches/com.apple.appstore",
        "~/Library/Caches/com.apple.Safari",
        "~/Library/Safari/LocalStorage",
        "~/Library/Safari/Databases"
    ]
    
    total_cleaned = 0
    
    for path in cache_paths:
        expanded_path = os.path.expanduser(path)
        if "*" in expanded_path:
            success, _ = run_command(f"du -sh {expanded_path} 2>/dev/null | awk '{{sum += $1}} END {{print sum}}'", ignore_errors=True)
            run_command(f"rm -rf {expanded_path}", use_sudo=True, ignore_errors=True)
        elif os.path.exists(expanded_path):
            try:
                size = get_folder_size(expanded_path)
                total_cleaned += size
                
                if os.path.isdir(expanded_path):
                    if "Library/Caches" in expanded_path:
                        for item in os.listdir(expanded_path):
                            item_path = os.path.join(expanded_path, item)
                            try:
                                if os.path.isdir(item_path):
                                    shutil.rmtree(item_path, ignore_errors=True)
                                else:
                                    os.remove(item_path)
                            except PermissionError:
                                run_command(f"rm -rf '{item_path}'", use_sudo=True, ignore_errors=True)
                    else:
                        shutil.rmtree(expanded_path, ignore_errors=True)
                else:
                    os.remove(expanded_path)
                    
            except PermissionError:
                run_command(f"rm -rf '{expanded_path}'", use_sudo=True, ignore_errors=True)
    
    print(f"  ✅ Total de cache limpo: {format_bytes(total_cleaned)}")

def clean_downloads_and_trash():
    """Limpa Downloads antigos e Lixeira"""
    print("🗑 Limpando Downloads antigos e Lixeira...")
    
    run_command("rm -rf ~/.Trash/*", ignore_errors=True)
    
    downloads_path = os.path.expanduser("~/Downloads")
    if os.path.exists(downloads_path):
        run_command(f"find '{downloads_path}' -type f -mtime +30 -delete", ignore_errors=True)
        print("  ✅ Removidos arquivos de Downloads com +30 dias")

def clean_logs():
    """Limpa logs antigos"""
    print("🗂 Limpando logs antigos...")
    
    log_paths = [
        "~/Library/Logs",
        "/var/log",
        "/Library/Logs",
        "~/Library/Containers/*/Data/Library/Logs",
        "/private/var/log/asl/*.asl"
    ]
    
    run_command("sudo log config --mode 'level:info,persist:debug' --subsystem com.apple.system", ignore_errors=True)
    
    for path in log_paths:
        expanded_path = os.path.expanduser(path)
        if "*" in expanded_path:
            run_command(f"find {os.path.dirname(expanded_path)} -name '{os.path.basename(expanded_path)}' -mtime +7 -delete", use_sudo=True, ignore_errors=True)
        elif os.path.exists(expanded_path):
            try:
                run_command(f"find '{expanded_path}' -name '*.log' -mtime +7 -delete", use_sudo=True, ignore_errors=True)
                run_command(f"find '{expanded_path}' -name '*.asl' -mtime +7 -delete", use_sudo=True, ignore_errors=True)
            except Exception as e:
                print(f"  ⚠️ Erro ao limpar logs em {path}: {e}")

def optimize_storage():
    """Otimiza armazenamento do macOS"""
    print("💾 Otimizando armazenamento...")
    
    run_command("sudo tmutil deletelocalsnapshots /", ignore_errors=True)
    
    photos_cache = "~/Pictures/Photos Library.photoslibrary/resources/caches"
    if os.path.exists(os.path.expanduser(photos_cache)):
        size = get_folder_size(os.path.expanduser(photos_cache))
        run_command(f"rm -rf '{os.path.expanduser(photos_cache)}'", ignore_errors=True)
        print(f"  ✅ Cache de Fotos limpo: {format_bytes(size)}")

def check_docker():
    """Limpa Docker"""
    print("🐳 Verificando e limpando Docker...")
    
    success, _ = run_command("docker --version", ignore_errors=True)
    if success:
        print("  🐳 Docker encontrado, executando limpeza...")
        
        run_command("docker stop $(docker ps -q)", ignore_errors=True)
        
        run_command("docker system prune -af --volumes")
        run_command("docker builder prune -af", ignore_errors=True)
        
        run_command("docker rmi $(docker images -f 'dangling=true' -q)", ignore_errors=True)
        
        print("  ✅ Limpeza do Docker concluída")
    else:
        print("  ℹ️ Docker não encontrado ou não está em execução")

def get_folder_size(folder_path):
    """Calcula tamanho de uma pasta"""
    total_size = 0
    try:
        for dirpath, dirnames, filenames in os.walk(folder_path):
            for filename in filenames:
                filepath = os.path.join(dirpath, filename)
                try:
                    total_size += os.path.getsize(filepath)
                except (OSError, IOError):
                    pass
    except Exception:
        pass
    return total_size

def format_bytes(bytes_size):
    """Formata bytes em formato legível"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_size < 1024.0:
            return f"{bytes_size:.1f} {unit}"
        bytes_size /= 1024.0
    return f"{bytes_size:.1f} PB"

def show_disk_usage():
    """Mostra uso do disco antes e depois"""
    success, output = run_command("df -h / | tail -1 | awk '{print $4}'", ignore_errors=True)
    if success:
        return output.strip()
    return "N/A"

if __name__ == "__main__":
    print("🚀 Iniciando manutenção avançada do macOS...\n")
    
    initial_space = show_disk_usage()
    print(f"💾 Espaço livre inicial: {initial_space}\n")

    update_system()
    clean_software_update_cache()
    clean_xcode_build_cache()  
    clean_ios_simulator_cache()  
    clean_caches()
    clean_downloads_and_trash()  
    clean_logs()
    optimize_storage()        
    check_docker()
    
    final_space = show_disk_usage()
    print(f"\n💾 Espaço livre final: {final_space}")
    print("\n✅ Manutenção avançada do macOS concluída!")
    print("💡 Recomenda-se reiniciar o sistema para aplicar todas as otimizações.")
    
    print("\n🔍 Para verificação adicional, execute:")
    print("   sudo fsck -fy")
    print("   sudo diskutil verifyVolume /")
