(* written on 27 ... 30 Oct 2004 *)

open Printf
open List
open Origami;;

let forlist a b =
  let rec forlist_a accum a b =
    if a > b then
      accum
    else
      forlist_a (b::accum) a (b-1)
  in
    forlist_a [] a b;;

let color_count = 64
let color_symbol i =
  if i < 0 || i > color_count then 
    raise(Failure "color_symbol")
  else if i = 0 then
    ' '
  else let i = i-1 in 
  if i < 26 then
    char_of_int ((int_of_char 'A')+i)
  else let i = i-26 in
  if i < 26 then
    char_of_int ((int_of_char 'a')+i)
  else let i = i-26 in
    char_of_int ((int_of_char '0')+i);;
    
let print_origami_colors () =
  print_string "\" c #FFFFFF\",\n";
  iter 
    ( fun i -> printf "\"%c c #00%2x00\",\n" (color_symbol i) (0xFF-7*i/2) )
    (forlist 1 64);;

let print_origami ori density =
  let colors = 10 in
  printf "static char * origami_xpm[] = {\n";
  printf "\"%d %d %d 1\",\n" (2*density+1) (2*density+2) (color_count + 1);
  print_origami_colors ();
  let (xs, ys) = density_map ori density 
  in
    iter 
      ( fun dy -> 
        print_string "\"";
        iter 
          ( fun dx -> printf "%c" (color_symbol (4*(Origami.perform ori {x=dx; y=dy}))) ) 
          xs;
        print_string "\",\n"
      ) 
      ys;
  printf "\"%s\"};\n\n" (String.make (2*density+1) ' ');;

let myorigami = 
  Origami.fold (Origami.id 2)
    [{x=(-.1.0); y=0.3}, {x=1.0; y=0.3};
     {x=0.0; y=0.0}, {x=1.0; y=1.4};
     {x=(-.1.0); y=0.0}, {x=0.8; y=1.4}];;

print_origami (Origami.fix myorigami) 300;;

(* vim:set et ts=2 sw=2: *)
