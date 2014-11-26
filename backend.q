\l json.k

/ Import data from csv into table
data: ("IIISI"; enlist ",") 0:`:data.csv

/ Protected execution: look up transform function by element for each row; if not available, no-op
transform:{[x] @[{eval each (x[`element] ,' til count x)};x;{[err] 0N! err; 0b}];x}
rock: :: / Silence error handler
soil: :: / Silence error handler

/ For elements of type tree
/ Grow: If energy level above X and directly upward is available, build a new tree
/ Eat: Check for elements of type soil or tree directly below
/   If soil energy > 1, take 1 energy
/   If tree energy > 20, take 1 energy
/   If soil energy <= 1, replace soil with tree (roots)
tree:{[row]
 loc:raze exec lx,ly,lz,energy from data where i=row;
 below:(select[1] from data where lx=loc[0],ly=loc[1]-1,lz=loc[2],((element like "soil") or (element like "tree")));
 $[(loc[3]>50) and (null (select[1] from data where lx=loc[0],ly=loc[1]+1,lz=loc[2])[`element][0]); 
  / Take energy from tree below and grow upward if space available
  [`data insert (loc[0];loc[1]+1;loc[2];`tree;25);
   data::update energy-25 from data where i=row;]; 
  (not null below[`element][0]) and (below[`energy][0]>1) and (below[`element][0] like "soil");
  [data::update energy-1 from data where lx=loc[0],ly=loc[1]-1,lz=loc[2];
   data::update energy+1 from data where i=row;]; 
  (not null below[`element][0]) and (below[`energy][0]>20) and (below[`element][0] like "tree");
  [data::update energy-1 from data where lx=loc[0],ly=loc[1]-1,lz=loc[2];
   data::update energy+1 from data where i=row;]; 
  (not null below[`element][0]) and (below[`energy][0]<=1);
  data::update element:`tree from data where lx=loc[0],ly=loc[1]-1,lz=loc[2];]} 

/ Tick: Transform data, JSON encode, and broadcast through web socket
.z.ts:{{neg[x] y}\:[key .z.W;.j.j transform data]}
\t 500
