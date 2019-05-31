%{
#include <stdio.h>
#include <math.h>

%}

CMTSIMPLE "//"[^\n]*
CMTCOMP   "/*"[^"*/"]*"*/"
PUNT      [,;()]
PRSTIPO   typedef|enum|struct|union|const|signed|unsigned|char|double|float|int|long|short|void
PRSSELEC  case|default|else|if|switch
PRITER    do|for|while
PRCLSVAR  auto|register|static|extern
PRSALTO   break|continue|goto|return
PROP      sizeof
ID        [_a-zA-Z][_a-zA-Z0-9]*
LITCADENA \".*\"
CTECAR    \'[a-zA-Z]?\'
CTEDEC    [1-9][0-9]*
CTEOCT    0[0-7]*
CTEHEX    0[xX][0-9a-fA-F]+
CTEREAL   [0-9]*"."[0-9]+([eE]([\+\-]?)[0-9]+)?
OPS       [\&\*\-\!"++"\*\+\"<"">""<=""<=""==""&&""||"\="+="] 
%%

%%