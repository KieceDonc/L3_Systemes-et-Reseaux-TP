#! /usr/bin/awk -f 

BEGIN{previous="";wordcmpt=0}
/ATOM/{
while read w;do
  wordcmpt+=1
  if ![ w -q previous ];then
    print $0
  fi
  if [ wordcmpt == 5 ]:then
    previous = w;
  fi
done < $0
}
END{}