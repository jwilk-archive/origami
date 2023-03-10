(* Copyright © 2004-2023 Jakub Wilk <jwilk@jwilk.net>
 * SPDX-License-Identifier: MIT
 *)

type vector = { x: float; y: float }
type origami

val id : int -> origami
val fold : origami -> (vector * vector) list -> origami
val transform : origami -> vector -> float -> origami
val fix : origami -> origami
val perform : origami -> vector -> int
val density_map : origami -> int -> float list * float list

(* vim:set et ts=2 sts=2 sw=2 tw=96: *)
