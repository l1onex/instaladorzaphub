#!/bin/bash
#
# Print banner art.

#######################################
# Print a board. 
# Globals:
#   BG_BROWN
#   NC
#   WHITE
#   CYAN_LIGHT
#   RED
#   GREEN
#   YELLOW
# Arguments:
#   None
#######################################
print_banner() {

  clear

  printf "\n\n"

printf "${CYAN_LIGHT}";

printf ${CYAN_LIGHT}" ZZZZZ  AAAAAAA  PPPP   H   H  U   U  BBBBB  \n"
printf ${CYAN_LIGHT}"    Z   A     A P    P  H   H  U   U  B    B \n"
printf ${CYAN_LIGHT}"   Z    AAAAAAA PPPPPP  HHHHH  U   U  BBBBB  \n"
printf ${CYAN_LIGHT}"  Z     A     A P       H   H  U   U  B    B \n"
printf ${CYAN_LIGHT}" ZZZZZ  A     A P       H   H  UUUUU  BBBBB  \n"

 

printf "${CYAN_LIGHT}";
  
  printf "${NC}";

  printf "\n"
}
