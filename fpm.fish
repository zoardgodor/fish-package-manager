#!/usr/bin/env fish
set -gx PAGER cat
clear
echo "Updating package list..."
sudo apt update
while true
    clear
    echo "FPM - Fish Package Manager"
    echo ---------------------
    echo "1. Package Installer"
    echo "2. Package Remover/Purger"
    echo "3. Remove Unused Packages (to save up space)"
    echo "4. Package Upgrader"
    echo "5. APT Cache cleaner (to save up space)"
    echo "q. Exit"
    echo ---------------------
    read -P "Enter your choice: " choice
    switch $choice
        case 1
            clear
            echo "Package Installer"
            read -P "Search: " search
            clear
            echo "searching…"
            set results (apt-cache search $search | string collect)
            set results (string split \n -- "$results")
            if test -z "$results"
                clear
                echo "No packages found."
                read -P "Press Enter to search again..."
                continue
            end
            set packages
            for result in $results
                set package (string split -m 1 " " $result)[1]
                set -a packages $package
            end
            set a 1
            for package in $packages
                echo "$a. $package"
                set a (math $a + 1)
            end
            read -P "Enter the number of the package to install (q for search again): " number
            if test $number = q
                continue
            end
            if not string match -rq '^[1-9][0-9]*$' -- "$number"; or test $number -gt (count $packages)
                clear
                echo "Invalid input selection."
                read -P "Press Enter to continue..."
                continue
            end
            if test $number -gt (count $packages)
                clear
                echo "Invalid input selection."
                read -P "Press Enter to continue..."
                continue
            end
            set selected $packages[$number]
            clear
            apt show $selected
            read -P "Install $selected? (y/n): " install
            if test $install = y
                clear
                sudo apt install $selected
                echo "$selected installed successfully."
                read -P "Press Enter to continue..."
                continue
            else
                echo "Installation cancelled."
                read -P "Press Enter to continue..."
            end
        case 2
            clear
            echo "Package Remover/Purger"
            read -P "Search: " search
            clear
            echo "searching…"
            set installed (dpkg-query -W -f='${binary:Package}\n' | grep -i $search)
            if test -z "$installed"
                clear
                echo "No installed packages found."
                read -P "Press Enter to search again..."
                continue
            end
            set asd 1
            for pack2 in $installed
                echo "$asd. $pack2"
                set asd (math $asd + 1)
            end
            read -P "Enter the number of the package to remove (q for search again): " number2
            if test $number2 = q
                continue
            end
            if not string match -rq '^[1-9][0-9]*$' -- "$number2"; or test $number2 -gt (count $installed)
                clear
                echo "Invalid input selection."
                read -P "Press Enter to continue..."
                continue
            end
            set selected $installed[$number2]
            clear
            read -P "Are you sure you want to remove $selected? (y/n): " rem
            if test $rem = y
                clear
            else
                echo "Removal cancelled."
                read -P "Press Enter to continue..."
                continue
            end
            read -P "Do you want to purge $selected? (y/n): " pur
            if test $pur = y
                clear
                sudo apt purge $selected
                echo "$selected purged successfully."
                read -P "Press Enter to continue..."
            else
                clear
                sudo apt remove $selected
                echo "$selected removed successfully."
                read -P "Press Enter to continue..."
                continue
            end
        case 3
            clear
            echo "Removing Unused Packages"
            sudo apt autoremove
            echo "Unused packages removed successfully."
            read -P "Press Enter to continue..."
        case 4
            clear
            echo "Package Upgrader"
            echo "..................."
            echo " "
            echo "1. Upgrade all packages"
            echo "2. Upgrade specific package"
            echo "3. List upgradable packages"
            echo " "
            read -P "Enter your choice: " upgradech
            switch $upgradech
                case 1
                    clear
                    echo "Upgrading all packages..."
                    sudo apt full-upgrade
                    echo "All packages upgraded successfully."
                    read -P "Press Enter to continue..."
                case 2
                    clear
                    echo "Upgrade specific package"
                    read -P "Search: " su
                    clear
                    set installed (dpkg-query -W -f='${binary:Package}\n' | grep -i $su)
                    if test -z "$installed"
                        clear
                        echo "No installed packages found."
                        read -P "Press Enter to search again..."
                        continue
                    end
                    set w 1
                    for pack11 in $installed
                        echo "$w. $pack11"
                        set w (math $w + 1)
                    end
                    read -P "Enter the number of the package to upgrade (q for search again): " number11
                    if test $number11 = q
                        continue
                    end
                    if not string match -rq '^[0-9]+$' "$number11"
                        clear
                        echo "Invalid input selection."
                        read -P "Press Enter to continue..."
                        continue
                    end
                    set selected2 $installed[$number11]
                    clear
                    sudo apt install --only-upgrade $selected2
                    echo "$selected2 upgraded successfully."
                    read -P "Press Enter to continue..."
                case 3
                    clear
                    echo "Upgradable packages"
                    sudo apt list --upgradable
                    read -P "Press Enter to continue..."
            end
        case 5
            clear
            sudo apt clean
            echo "APT Cache cleaned"
            read -P "Press enter to continue..."
        case q
            clear
            echo "Exiting..."
            exit
        case '*'
            echo "Invalid choice. Please try again."
            read -P "Press Enter to continue..."
    end
end
