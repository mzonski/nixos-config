{ pkgs }:
pkgs.writeShellScript "bash-colors-functions" ''
   reset_color() {
       echo -e "\033[0m$1"
   }

   text_black() {
       echo -e "\033[30m$1\033[0m"
   }

   text_red() {
       echo -e "\033[31m$1\033[0m"
   }

   text_green() {
       echo -e "\033[32m$1\033[0m"
   }

   text_yellow() {
       echo -e "\033[33m$1\033[0m"
   }

   text_blue() {
       echo -e "\033[34m$1\033[0m"
   }

   text_magenta() {
       echo -e "\033[35m$1\033[0m"
   }

   text_cyan() {
       echo -e "\033[36m$1\033[0m"
   }

  text_white() {
       echo -e "\033[37m$1\033[0m"
   }

   text_bright_black() {
       echo -e "\033[90m$1\033[0m"
   }

  text_bright_red() {
       echo -e "\033[91m$1\033[0m"
   }

   text_bright_green() {
       echo -e "\033[92m$1\033[0m"
   }

   text_bright_yellow() {
       echo -e "\033[93m$1\033[0m"
   }

   text_bright_blue() {
       echo -e "\033[94m$1\033[0m"
   }

   text_bright_magenta() {
       echo -e "\033[95m$1\033[0m"
   }

   text_bright_cyan() {
       echo -e "\033[96m$1\033[0m"
   }

   text_bright_white() {
       echo -e "\033[97m$1\033[0m"
   }

   bg_black() {
       echo -e "\033[40m$1\033[0m"
   }

   bg_red() {
       echo -e "\033[41m$1\033[0m"
   }

   bg_green() {
       echo -e "\033[42m$1\033[0m"
   }

   bg_yellow() {
       echo -e "\033[43m$1\033[0m"
   }

   bg_blue() {
       echo -e "\033[44m$1\033[0m"
   }

   bg_magenta() {
       echo -e "\033[45m$1\033[0m"
   }

   bg_cyan() {
       echo -e "\033[46m$1\033[0m"
   }

   bg_white() {
       echo -e "\033[47m$1\033[0m"
   }

   text_bold() {
       echo -e "\033[1m$1\033[0m"
   }

   text_dim() {
       echo -e "\033[2m$1\033[0m"
   }

   text_italic() {
       echo -e "\033[3m$1\033[0m"
   }

   text_underline() {
       echo -e "\033[4m$1\033[0m"
   }

   text_blink() {
       echo -e "\033[5m$1\033[0m"
   }

   text_reverse() {
       echo -e "\033[7m$1\033[0m"
   }

   text_strikethrough() {
       echo -e "\033[9m$1\033[0m"
   }

   text_error() {
       echo -e "\033[1;31m$1\033[0m"
   }

   text_success() {
       echo -e "\033[1;32m$1\033[0m"
   }

   text_warning() {
       echo -e "\033[1;33m$1\033[0m"
   }

   text_info() {
       echo -e "\033[1;34m$1\033[0m"
   }
''
