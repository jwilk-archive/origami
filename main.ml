(* written on 27 ... 30 Oct, 7 Nov 2004 *)

open Printf
open List

let color_count = 64
let color_symbol i =
  if i < 0 then
    raise(Failure "color_symbol")
  else if i > color_count then
    '9'
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
    (Forlist.forlist 1 64);;

let print_origami ori density =
  printf "static char * origami_xpm[] = {\n";
  printf "\"%d %d %d 1\",\n" (2*density+1) (2*density+2) (color_count + 1);
  print_origami_colors ();
  let (xs, ys) = Origami.density_map ori density
  in
    iter
      ( fun dy ->
        print_string "\"";
        iter
          ( fun dx ->
            printf "%c"
              (color_symbol
                (Origami.perform ori {Origami.x=dx; Origami.y=dy})
              )
          )
          xs;
        print_string "\",\n"
      )
      ys;
  printf "\"%s\"};\n\n" (String.make (2*density+1) ' ');;

let fetch_data () =
  let ptpair x1 y1 x2 y2 =
    { Origami.x=x1; Origami.y=y1 },
    { Origami.x=x2; Origami.y=y2 }
  in
  let rec fetch_data_helper accum =
    try
      fetch_data_helper ((Scanf.scanf "(%f,%f) (%f,%f)\n" ptpair)::accum)
    with
      End_of_file -> accum
  in
  let id = Scanf.scanf "F%u\n" (fun x -> x) in
  let data = fetch_data_helper [] in
    (id, List.rev data);;

let myorigami =
  let (id, data) = fetch_data () in
    Origami.fold (Origami.id id) data;;

if not Sys.interactive.contents then
  print_origami (Origami.fix myorigami) 300;;

(* vim:set et ts=2 sts=2 sw=2 tw=96: *)
