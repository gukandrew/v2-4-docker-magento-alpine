#!/bin/bash
while :
do
  clear
  echo "Select an option ..."
  echo "1) magento console"
  echo "2) database console"
  echo "3) magento cache flush"
  echo "4) magento redeploy"
  echo "5) magento disable sso and ugly admin theme"
  echo "6) replace prod urls to local"
  echo "7) reset user's password"
  echo "8) generate static - adminhtml/Magento"
  echo "9) generate static - Infortis/*"
  echo "Press Ctrl+C to exit"

  read INPUT_STRING
  case $INPUT_STRING in
  1)
    clear && \
    docker-compose exec -uwww-data web /bin/sh

    echo && \
    read -p "Done! Press any key to return to main menu..." -n 1 -r
    ;;

  2)
    clear && \
    docker-compose exec db /bin/sh

    echo && \
    read -p "Done! Press any key to return to main menu..." -n 1 -r
   ;;

  3)
    clear && \
    echo "Clearing Magento cache. Please wait ..." && \

    echo " - Recreating folders" && \

    echo "   * var/cache recreate" && \
    docker-compose exec -u www-data web /bin/sh -c "rm -rf var/cache && mkdir var/cache" && \
    echo "   * var/cache set chmod 777" && \
    docker-compose exec -u www-data web /bin/sh -c "chmod 777 -R var/cache" && \

    echo "   * var/view_preprocessed recreate" && \
    docker-compose exec -u www-data web /bin/sh -c "rm -rf var/view_preprocessed && mkdir var/view_preprocessed" && \
    echo "   * var/view_preprocessed set chmod 777" && \
    docker-compose exec -u www-data web /bin/sh -c "chmod 777 -R var/view_preprocessed" && \

    echo " - Flushing cache" && \
    docker-compose exec -u www-data web /bin/sh -c "bin/magento c:f" && \

    # echo " - Flushing Varnish container" && \
    # docker-compose up --build -d varnish

    echo && \
    read -p "Done! Press any key to return to main menu..." -n 1 -r
    ;;

  4)
    clear  && \
    echo "(Re)Deploying Magento. Please wait ..."

    while [[ $RUN_COMPOSER_INSTALL != [yYn] ]]
    do
      read -e -p "Run composer install? (y/n) " -i "n" RUN_COMPOSER_INSTALL
    done

    while [[ $DISABLE != [yYn] ]]
    do
      read -e -p "Disable Wizkunde_WebSSO and Netbaseteam? (y/n) " -i "n" DISABLE
    done

    while [[ $GEN_ADMIN_STATICS != [yYn] ]]
    do
      read -e -p "Generate statics for default Magento Admin Theme? (y/n) " -i "n" GEN_ADMIN_STATICS
    done

    if [[ $DISABLE != [yY] ]]
    then
      while [[ $RUN_DI_COMPILE != [yYn] ]]
      do
        read -e -p "Run DI compile? (y/n) " -i "n" RUN_DI_COMPILE
      done
    fi

    deploy_started=$(date +%s)

    docker-compose exec web /bin/sh -c "chown -R www-data:www-data /var/www" && \

    echo " - Recreating folders" && \

    # echo "   * generated recreate" && \
    # docker-compose exec -u www-data web /bin/sh -c "rm -rf generated && mkdir generated" && \
    echo "   * generated set chmod 777" && \
    docker-compose exec -u www-data web /bin/sh -c "chmod 777 -R generated" && \

    echo "   * var/cache recreate" && \
    docker-compose exec -u www-data web /bin/sh -c "rm -rf var/cache && mkdir var/cache" && \
    echo "   * var/cache set chmod 777" && \
    docker-compose exec -u www-data web /bin/sh -c "chmod 777 -R var/cache" && \

    echo "   * var/view_preprocessed recreate" && \
    docker-compose exec -u www-data web /bin/sh -c "rm -rf var/view_preprocessed && mkdir var/view_preprocessed" && \
    echo "   * var/view_preprocessed set chmod 777" && \
    docker-compose exec -u www-data web /bin/sh -c "chmod 777 -R var/view_preprocessed" && \

    # echo "   * pub/static recreate" && \
    # docker-compose exec -u www-data web /bin/sh -c "rm -rf pub/static && mkdir pub/static" && \
    echo "   * pub/static set chmod 777" && \
    docker-compose exec -u www-data web /bin/sh -c "chmod 777 -R pub/static" && \

    if [[ $RUN_COMPOSER_INSTALL == [yY] ]]
    then
      echo "   * vendor recreate" && \
      docker-compose exec -u www-data web /bin/sh -c "rm -rf vendor && mkdir vendor" && \
      echo "   * vendor set chmod 777" && \
      docker-compose exec -u www-data web /bin/sh -c "chmod 777 -R vendor" && \

      echo " - Running 'composer install'" && \
      docker-compose exec -u www-data web /bin/sh -c "composer install"
    fi

    if [[ $DISABLE == [yY] ]]
    then
      echo " - Disabling Wizkunde_WebSSO" && \
      echo " - Disabling UGLY admin theme" && \
      docker-compose exec -u www-data web /bin/sh -c "bin/magento module:disable -n Wizkunde_WebSSO Netbaseteam_Admintheme Netbaseteam_Themeconfig"
    fi

    echo " - Running Magento Upgrade" && \
    docker-compose exec -u www-data web /bin/sh -c "bin/magento setup:upgrade --keep-generated" && \

    if [[ $RUN_DI_COMPILE == [yY] || $DISABLE == [yY] ]]
    then
      echo " - Running Magento DI compile" && \
      docker-compose exec -u www-data web /bin/sh -c "bin/magento setup:di:compile -n --no-ansi"
    fi

    if [[ $GEN_ADMIN_STATICS == [yY] ]]
    then
      echo " - Generate statics for Magento/backend theme" && \
      docker-compose exec -u www-data web /bin/sh -c "php -d memory_limit=4096M \
        bin/magento setup:static-content:deploy en_US -j8 -f --theme='Magento/backend'"
    fi

    echo " - Flushing cache" && \
    docker-compose exec -u www-data web /bin/sh -c "bin/magento c:f" && \

    # echo " - Flushing Varnish container" && \
    # docker-compose up --build -d varnish

    deploy_time=`expr $(date +%s) - $deploy_started`

    echo  && \
    read -p "Done! Deploy finished in $deploy_time seconds Press any key to return to main menu..." -n 1 -r
    ;;

  5)
    clear && \
    echo "Disable Magento SSO and UGLY admin theme. Please wait ..."
    docker-compose exec web /bin/sh -c "chown -R www-data:www-data /var/www"

    echo " - Disabling Wizkunde_WebSSO" && \
    echo " - Disabling UGLY admin theme" && \
    docker-compose exec -u www-data web /bin/sh -c "bin/magento module:disable -n Wizkunde_WebSSO Netbaseteam_Admintheme Netbaseteam_Themeconfig" && \

    echo " - Running Magento DI compile" && \
    docker-compose exec -u www-data web /bin/sh -c "bin/magento setup:di:compile -n --no-ansi" && \

    echo " - Flushing cache" && \
    docker-compose exec -u www-data web /bin/sh -c "bin/magento c:f" && \

    # echo " - Flushing Varnish container" && \
    # docker-compose up --build -d varnish

    echo && \
    read -p "Done! Press any key to return to main menu..." -n 1 -r
    ;;

  6)
    clear
    echo "Here you can replace production URLs to local."
    DBNAME=''
    while [[ $DBNAME == '' ]]
    do
      read -e -p "Type database name to use: " -i "shop" DBNAME
    done

    URLTOFIND=""
    while [[ $URLTOFIND == '' ]]
    do
      read -e -p "URL to find: " -i "$DBNAME.dermpro.com" URLTOFIND
    done

    URLTOREPLACE=""
    while [[ $URLTOREPLACE == '' ]]
    do
      read -e -p "URL to replace: " -i "local.$DBNAME.dermpro.com" URLTOREPLACE
    done

    storecode="`echo "$URLTOREPLACE" | grep -o '\w*$'`"
    basedomain=${URLTOREPLACE//\/$storecode/}

    echo " - Resetting admin password to 'admin123'" && \
    docker-compose exec db /bin/sh -c "mysql $DBNAME -e \"\
      update admin_user set password = concat(sha2('admin123', 256), '::1') where username = 'admin';\"" && \

    echo " - Replacing urls '$URLTOFIND' to '$URLTOREPLACE' in 'core_config_data'" && \
    docker-compose exec db /bin/sh -c "mysql $DBNAME -e \"\
      update core_config_data set value = replace(value, '$URLTOFIND', '$URLTOREPLACE') where value like '%$URLTOFIND%';\
      update core_config_data set value = replace(value, '$URLTOREPLACE/static', '$basedomain/static') where value like '%$URLTOREPLACE/static%';\
      update core_config_data set value = replace(value, '$URLTOREPLACE/media', '$basedomain/media') where value like '%$URLTOREPLACE/media%';\
      update core_config_data set value = replace(value, 'local.local.', 'local.') where value like '%local.local.%';\
      update core_config_data set value = replace(value, 'https', 'http') where value like '%https%';\"" && \

    echo " - Disabling secure web serving on admin and frontend" && \
    docker-compose exec db /bin/sh -c "mysql $DBNAME -e \"\
      update core_config_data set value = 0 where path = 'web/secure/use_in_adminhtml';\
      update core_config_data set value = 0 where path = 'web/secure/use_in_frontend';\"" && \

    echo " - Moving all stores bluepay to TEST mode" && \
    docker-compose exec db /bin/sh -c "mysql $DBNAME -e \"\
      update core_config_data set value = 'test' where path = 'payment/bluepay_payment/trans_mode' and value like '%live%';\"" && \

    echo " - Setting test SMTP configuration" && \
    docker-compose exec db /bin/sh -c "mysql $DBNAME -e \"\
      update core_config_data set value = 'maildev' where path = 'smtp/configuration_option/host';\
      update core_config_data set value = '1025' where path = 'smtp/configuration_option/port';\
      update core_config_data set value = null where path = 'smtp/configuration_option/protocol';\
      update core_config_data set value = null where path = 'smtp/configuration_option/authentication';\
      update core_config_data set value = '' where path = 'smtp/configuration_option/username';\
      update core_config_data set value = '' where path = 'smtp/configuration_option/password';\"" && \

    echo " - Disabling all Captchas" && \
    docker-compose exec db /bin/sh -c "mysql $DBNAME -e \"\
      update core_config_data set value = 0 where path like '%captcha/enabled%';\"" && \

    echo " - Flushing cache" && \
    docker-compose exec -u www-data web /bin/sh -c "bin/magento c:f" && \

    # echo " - Flushing Varnish container" && \
    # docker-compose up --build -d varnish

    echo && \
    read -p "Done! Press any key to return to main menu..." -n 1 -r
    ;;

  7)
    clear
    echo "Here you can reset admin user password."
    DBNAME=''
    while [[ $DBNAME == '' ]]
    do
      read -e -p "Type database name: " -i "shop" DBNAME
    done

    USERNAME=""
    while [[ $USERNAME == '' ]]
    do
      read -e -p "Type username to reset password: " -i "admin" USERNAME
    done

    NEWPASS=""
    while [[ $NEWPASS == '' ]]
    do
      read -e -p "Type new password for user '$USERNAME': " -i "admin123" NEWPASS
    done


    docker-compose exec db /bin/sh -c "mysql $DBNAME -e \"\
      update admin_user set password = concat(sha2('$NEWPASS', 256), '::1') where username = '$USERNAME';\""

    echo && \
    read -p "Done! Press any key to return to main menu..." -n 1 -r
    ;;

  8)
    clear
    echo "Here you can generate statics for admin panel."
    THEMENAME=''
    while [[ $THEMENAME == '' ]]
    do
      read -e -p "Type Vendor/Theme name: " -i "Magento/backend" THEMENAME
    done

    docker-compose exec -u www-data web /bin/sh -c "php -d memory_limit=4096M \
      bin/magento setup:static-content:deploy en_US -j8 -f --theme='$THEMENAME'"

    echo && \
    read -p "Done! Press any key to return to main menu..." -n 1 -r
    ;;

  9)
    clear
    echo "Here you can generate statics for Infortis theme."
    THEMENAME=''
    while [[ $THEMENAME == '' || $THEMENAME == 'Infortis/' ]]
    do
      read -e -p "Type Vendor/Theme name: " -i "Infortis/" THEMENAME
    done

    docker-compose exec -u www-data web /bin/sh -c "php -d memory_limit=4096M \
      bin/magento setup:static-content:deploy en_US -j8 -f --theme='$THEMENAME'"

    echo && \
    read -p "Done! Press any key to return to main menu..." -n 1 -r
    ;;

  *)
    read -p "Sorry, I don't understand. Press any key to return to main menu..." -n 1 -r
    ;;
  esac
done
