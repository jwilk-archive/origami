let forlist a b =
  let rec forlist_a accum a b =
    if a > b then
      accum
    else
      forlist_a (b::accum) a (b-1)
  in
    forlist_a [] a b;;

(* vim:set et ts=2 sts=2 sw=2 tw=96: *)
