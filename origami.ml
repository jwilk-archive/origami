open Printf;;

(** VECTOR ALGEBRA ****************************************************************************)

type vector = { x: float; y: float };;

let v_add p q =
  { x = p.x +. q.x; y = p.y +. q.y };;

let v_diff p q =
  { x = p.x -. q.x; y = p.y -. q.y };;

let v_prod p q =
  (p.x *. q.y) -. (p.y *. q.x);;

let v_length p =
  sqrt ((p.x *. p.x) +. (p.y *. p.y));;

let v_perp p deslen =
  let mul = deslen /. (v_length p) in
    { x = p.y *. mul; y = -. p.x *. mul};;

(** ORIGAMI SIMPLE FIGURES ********************************************************************)

type origami = { testfun: vector -> int; zeropoint: vector; radius: float};;

let id1 =
  let idfun =
    function ask ->
      if (
        (ask.x>=0.0) &&
        (ask.y>=0.0) &&
        (ask.x<=1.0) &&
        (ask.y<=1.0))
      then 1 else 0
  in {testfun = idfun; zeropoint = {x=0.5; y=0.5}; radius = sqrt(2.0)};;

let id2 =
  let idfun =
    function ask ->
      if (ask.x *. ask.x +. ask.y *. ask.y <= 1.0)
      then 1 else 0
  in
    { testfun = idfun; zeropoint = {x=0.0; y=0.0}; radius = 1.0 };;

let id3 =
  let idfun =
    function ask ->
      if (ask.x *. ask.y <= 1.0)
      then 1 else 0
  in
    { testfun = idfun; zeropoint = {x=0.0; y=0.0}; radius = 1.0 };;

let id n =
  match n with
    0 -> id1 |
    1 -> id2 |
    2 -> id3 |
    _ -> raise(Failure "id");;

(** ORIGAMI ACCESS ****************************************************************************)

let perform ori =
  ori.testfun;;

(** ORIGAMI TRANSFORMATIONS: FOLDING **********************************************************)

let fold1 ori (p, q) =
  let
    newfun ask =
      let
        dask = v_diff ask p and
        lv = v_diff q p
      in let
        field = v_prod lv dask
      in if field < 0.0
      then
        0
      else
        let dist = 2.0 *. field /. v_length lv in
        let ask2 = v_add ask (v_perp lv dist)
        in
          (ori.testfun ask) + (ori.testfun ask2)
  and
    zeropoint =
      let
        dz = v_diff ori.zeropoint p and
        lv = v_diff q p
      in
        let field = v_prod lv dz in
        if field > 0.0
        then
          ori.zeropoint
        else
          let dist = 2.0 *. field /. v_length lv in
          v_add ori.zeropoint (v_perp lv dist)
  in
    { testfun=newfun; zeropoint=zeropoint; radius=ori.radius };;

let fold id =
  List.fold_left fold1 id;;

(** ORIGAMI DENSITY MAP ***********************************************************************)

let density_map ori density =
  let fdensity = float_of_int density in
  let mul = ori.radius *. 1.05 /. fdensity in
  let
    us = List.map (fun n -> (float_of_int n) *. mul) (Forlist.forlist (-density) density)
  in let
    xs = List.map (fun x -> x +. ori.zeropoint.x) us and
    ys = List.map (fun y -> y +. ori.zeropoint.y) us
  in
    (xs, ys);;

(** ORIGAMI TRANSFORMATIONS: OTHER ************************************************************)

let normalize ori =
  let newfun ask =
    ori.testfun
      { x = ori.radius *. ask.x +. ori.zeropoint.x;
        y = ori.radius *. ask.y +. ori.zeropoint.y; }
  in
    { testfun = newfun; zeropoint = {x=0.0;y=0.0}; radius = 1.0; }

let transform ori newzp newradius =
  let ori = normalize ori in
  let newfun ask =
    ori.testfun
      { x = (ask.x -. newzp.x) /. newradius;
        y = (ask.y -. newzp.y) /. newradius }
  in
    { testfun = newfun; zeropoint = newzp; radius = newradius; }

let fix ori =
  let density = 40 in
  let (xs, ys) = density_map ori density in
  let za = ori.zeropoint.x, ori.zeropoint.y, ori.zeropoint.x, ori.zeropoint.y in
  let (minx, miny, maxx, maxy) =
    List.fold_left
      ( fun ac y ->
        List.fold_left
          ( fun ac x ->
            if ori.testfun {x=x; y=y} = 0 then
              ac
            else
              let (minx, miny, maxx, maxy) = ac in
                (min minx x, min miny y, max maxx x, max maxy y)
          )
          ac xs
      )
      za ys in
  let rx = maxx-.minx and ry = maxy-.miny
  in
    { testfun = ori.testfun;
      zeropoint = { x = (maxx+.minx)/.2.0; y = (maxy+.miny)/.2.0 };
      radius = sqrt(rx*.rx+.ry*.ry)/.2.0 }

(* vim:set et ts=2 sts=2 sw=2 tw=96: *)
