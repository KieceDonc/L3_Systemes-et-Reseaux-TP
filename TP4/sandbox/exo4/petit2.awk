#! /usr/bin/awk -f 

BEGIN{NBRE0=0;NBRE3=0;NBRE300}
/REMARK 0/{NBRE0+=1}
/REMARK 3/{NBRE3+=1}
/REMARK 300/{NBRE300+=1}
END{if(NBRE0>NBRE3){
  if(NBRE0>300){
    print"REMARK 0 en tête avec "NBRE0
  }
  }else if(NBRE3>NBRE300){
    print"REMARK 3 en tête avec "NBRE3
  }else{
    print"REMARK 300 en tête avec "NBRE300
  }
}
