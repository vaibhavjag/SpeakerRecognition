#!/bin/awk - makeDocs


BEGIN{flag=1;printf("====================================================================================\n");}
/^%/{if(flag)print;next}
/^function/{print; next;}
{if(length($0)>0){flag=0;}}
END{printf("\n\n");}


