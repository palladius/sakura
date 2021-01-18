#!/usr/bin/env ruby

# Filter that fixes code oin INPUT which is 
# Number of readings to fix this.

# INPUT: "opportunitÃ    di persona. Se Ã¨ perchÃ¨ ho occasione o perchÃ¨. HTML: guarderÃ  storto, vi considererÃ  gay e forse cercherÃ  la rissa (HTML)" 
# OUTPUT: 

# TODO ricc: also see www.goliardia.it-github/bin/fix-encoding.sh
#      where problem is  # HEXDUMP STUDY: i caratteri sono purtroppo indistinguibili: tutti "ef bf bd"
#       "s/dar�/darà/g" |
#       sed -e "s/sar�/sarà/g" | # puo essere saro'# ma chissene

# TODO use 

def get_input
    #TODO stdin
    "opportunitÃ di incontrarti di persona. Non so se Ã¨ perchÃ¨ non ho cercato abbastanza l' occasione o perchÃ¨. PerÃ² piÃ¹ guarderÃ." 
end    

def process_input(s)
    # inefficient but who cares
    ret = s.
        #########################
        #\ A  Átha, Ã, semplicitÃ . Città  B         città 
        # guarderÃ  storto, vi considererÃ  gay e forse cercherÃ  la rissa
        gsub(/Ã /, "à").
        #########################
        # è - e grave / Ã¨
        gsub(/Ã¨/,"è").
        #########################
        # é - e acuta \ perchÃ© VabbÃ¨ PerchÃ©
        gsub(/Ã©/,"é").
        #########################
        # I = cosÃ¬  così
        gsub(/Ã¬/, "ì").

        #########################
        # può TODO -  perÃ² - a m
        gsub(/Ã²/, "ò").

        #########################
        # U - piÃ¹  più
        gsub(/Ã¹/,"ù").

        #########################
        # end
        # TODO removeme - just to keep the final dots going
        gsub(/DoesntExist3487fgerfugey/,"Just so I can have a DOT at the end of every part :)")
    return ret 
end



def main()
    puts "#DEB Welcome to $0"
    s=get_input()
    puts "Original: #{s}"
    puts "Fixed:    #{process_input s}"
 #   puts process_input(get_input())
end


# call main only if its not called as module...
if $0 ==  __FILE__
    main
else
    puts '#DEB Thanks for INCLUDING me, I suspect on IRB. Dop whatever you want of me. Maybe start with main().'
end
