# Application to manage fundamental operations of PostgreSQL, like installation, uninstall, generate and restore backups.
# Autor: Luis Xavier Pérez | xavierpm1221@gmail.com

while :
do
    # Clear screen
    clear
    # Option Menu
    echo "---------------------------------------------------"
    echo "PostgreSQL Utilities - Utility program for Postgres"
    echo "---------------------------------------------------"
    echo "                  MAIN MENU                        "
    echo "---------------------------------------------------"
    echo "1. Install Postgres"
    echo "2. Uninstall Postgres"
    echo "3. Create a Backup"
    echo "4. Restore Backup"
    echo "5. Exit"

    # Read data from the user
    read -p "Enter your option (1-5): " option

    # Validate the entered option
    case $option in
        1)  install_postgres
            sleep 1
            ;;

        2)  uninstall_postgres
            sleep 1
            ;;

        3)  read -p "Enter the Directory you want to create a backup: " directory
            create_backup $directory
            sleep 1
            ;;

        4)  read -p "Enter the Backup Directory: " backupDirectory
            restore_backup $backupDirectory
            sleep 1
            ;;
        
        5)  echo -e "\nExit Program..."
            sleep 1
            exit 0
            ;;

        *)  echo -e "\nWrong option"
            sleep 1
            ;;

    esac
done
