# Signus
# https://github.com/Signus
# Installs the latest version of Sublime Text 3

# TODO: Add dynamic zsh/bash checking for shebang
# TODO: Add Mac OSX installation support
# TODO: Add deb installation  support

SUBL_URL="https://sublimetext.com/3"
TMP_DIR="/tmp/sublime_text_install"

DEB_REGEX="href\=(\"|\')(.+?\.(deb))(\"|\')"
LIN_REGEX="href\=(\"|\')(.+?\.(tar\.bz2))(\"|\')"
MAC_REGEX="href\=(\"|\')(.+?\.(dmg))(\"|\')"

OS_ARCH=""
OS_REGEX=""
OS_CLEAN=""

show_usage() {
    echo -e "Usage: $0 [-o <os_type>] [-a <os_arch>] [ -c <cleanup>]"
    echo -e "\t-o <os_type> Debian/Ubuntu, Linux, or Mac (deb|lin|mac) [Required]"
    echo -e "\t-a <os_arch> 32 or 64 bit [Required]"
    echo -e "\t-c <clean> Removes the working directory after installation [Optional]"
}

show_error() {
    echo -e "Invalid arguments supplied"
    show_usage
    exit 1
}

download_file() {
    mkdir -p $TMP_DIR

    file=$(curl -s $SUBL_URL \
           | grep -oP "<a [^>]+>" \
           | grep -oP "$OS_REGEX" \
           | grep "$OS_ARCH" \
           | awk -F \" '{print $2}')

    wget $file -P $TMP_DIR -q --show-progress
}

install_subl() {
    echo "Weee"
    cd $TMP_DIR
    # Determine the type that was downloaded or save it in a variable so we know how to extract
}

cleanup() {
    rm -rf $TMP_DIR
}


while getopts ":o:a:c:h:" opts; do
    case "${opts}" in
        o)
            o=$(echo ${OPTARG} | awk '{print tolower($0)}')
            [[ $o = "deb" || $o = "lin" || $o = "mac" ]] || show_error 
            [[ $o = "deb" ]] && OS_REGEX="$DEB_REGEX" &&
            [[ $o = "lin" ]] && OS_REGEX="$LIN_REGEX"
            [[ $o = "mac" ]] && OS_REGEX="$MAC_REGEX"
            ;;
        a)
	        [[ ${OPTARG} = "32" || ${OPTARG} = "64" ]] || show_error
	        OS_ARCH="${OPTARG}"
	        ;;
	    c)
	        [[ ${OPTARG} = "true" ]] || show_error
	        OS_CLEAN="${OPTARG}"
	        ;;
	    h)
	        show_usage
	        ;;
        *)
            show_error
            ;;
    esac
done
shift $((OPTIND-1))

download_file
install_subl

[[ $OS_CLEAN = "true" ]] && cleanup
