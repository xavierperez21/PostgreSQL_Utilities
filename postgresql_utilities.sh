# Application to manage fundamental operations of PostgreSQL, like installation, uninstall, generate and restore backups.
# Autor: Luis Xavier Pérez | xavierpm1221@gmail.com

option=0
actual_date=$(date +%Y_%m_%d)


install_postgres () {
    echo -e "\nVerifying Postgres installation..."
    verifyInstall=$(which psql)
    if [[ $? -eq 0 ]]; then
        echo -e "\nPostgres is already installed"
    else
        read -sp "Enter password for xavier: " password
        echo -e "\n"
        read -sp "Enter password to use in Postgres: " passwordPostgres
        echo "$password" | sudo -S apt update
        echo "$password" | sudo -S apt -y install postgresql postgresql-contrib
        sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '{$passwordPostgres}';"
        echo "$password" | sudo -S systemctl enable postgresql.service
        echo "$password" | sudo -S systemctl start postgresql.service
    fi
    read -n 1 -s -r -p "CLICK [ENTER] to continue..."
}


uninstall_postgres () {
    read -sp "Enter password for xavier: " password
    echo -e "\n"
    echo "$password" | sudo -S systemctl stop postgresql.service
    echo "$password" | sudo -S apt -y --purge remove postgresql\*
    echo "$password" | sudo -S rm -r /etc/postgresql
    echo "$password" | sudo -S rm -r /etc/postgresql-common
    echo "$password" | sudo -S rm -r /var/lib/postgresql
    echo "$password" | sudo -S deluser -r postgresql
    echo "$password" | sudo -S delgroup -r postgresql
    read -n 1 -s -r -p "CLICK [ENTER] to continue..."
}


create_backup () {
    echo "Listing the databases..."
    sudo -u postgres psql -c "\l"
    read -p "Choose the database to create a backup: " bd_backup
    echo -e "\n"

    if [[ -d "$1" ]]; then
        echo "Stablishing permissions to the directory"
        echo "$password" | sudo -S chmod 755 $1
        echo "Creating Backup..."
        sudo -u postgres pg_dump -Fc $bd_backup > "$1/bd_backup_$actual_date.bak"
        echo "Backup created succedfully in: $1/bd_backup_$actual_date.bak"
    else
        echo "The directory $1 doesn't exist"
    fi
    read -n 1 -s -r -p "CLICK [ENTER] to continue..."
}


restore_backup () {
    if [[ -d $1 ]]; then
        while :
        do
            echo "Listing the backups..."
            ls -l $1/*.bak
            read -p "Choose the backup to restore: " backupRestore
            if [[ -f "$1/$backupRestore" ]]; then
                break
            else
                echo "The backup file $backupRestore doesn't exist"
            fi
        done
        echo -e "\n"
        echo "Listing all the databases"
        sudo -u postgres psql -c "\l"
        read -p "Enter the name of the destination database: " destinationDataBase
        
        # Verifying if the db exists
        verifyDB=$(sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -wq $destinationDataBase)
        
        if [[ $? -eq 0 ]]; then
            echo "Restoring backup in the destination Database"
        else
            sudo -u postgres psql -c "CREATE DATABASE $destinationDataBase"
        fi
    
        echo "Restoring backup..."
        sudo -u postgres pg_restore -Fc -d $destinationDataBase "$1/$backupRestore"
        echo "Listing databases..."
        sudo -u postgres psql -c "\l"
    else
        echo "The directory $1 doesn't exist"
    fi
    read -n 1 -s -r -p "CLICK [ENTER] to continue..."
}


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
