
type tree = Node of int * int * (int list) * (tree list)
type heap = tree list

let empty : heap = []

let isEmpty = function [] -> true | _ -> false

let rank = function Node(r, x, xs, c) -> r
let root = function Node(r, x, xs, c) -> x

let link t1 t2 =
  let Node(r, x1, xs1, c1) = t1 in 
  let Node(_, x2, xs2, c2) = t2 in
    if x1 <= x2 then
      Node(r+1, x1, xs1, t2::c1)
    else
      Node(r+1, x2, xs2, t1::c2)

let skewLink x t1 t2 = 
  let Node(r, y, ys, c) = link t1 t2 in
  if x <= y then
    Node(r, x, y::ys, c)
  else
    Node(r, y, x::ys, c)

let rec insTree t1 t2 = 
  match t2 with
  |[] -> [t1]
  |t2::ts -> if rank t1 < rank t2 then t1::t2::ts else insTree (link t1 t2) ts

let rec mergeTrees = function 
  |(ts1, []) -> ts1
  |([], ts2) -> ts2
  |((t1::ts1_ as ts1), (t2::ts2_ as ts2)) -> 
    if rank t1 < rank t2 then t1::(mergeTrees(ts1_, ts2))
    else if rank t2 < rank t1 then t2::(mergeTrees(ts1, ts2_))
    else insTree (link t1 t2) (mergeTrees(ts1_, ts2_))

let normalize = function
  |[] -> []
  |t::ts -> insTree t ts

let insert x ts =
  match ts with 
  |t1::t2::rest when rank t1 == rank t2 -> (skewLink x t1 t2)::rest
  |_ -> Node(0, x, [], [])::ts

let merge ts1 ts2 = mergeTrees(normalize ts1, normalize ts2)

exception Empty

let rec removeMinTree = function
  |[] -> raise Empty
  |[t] -> (t, [])
  |t::ts -> let (t_, ts_) = removeMinTree ts in
            if (root t) < (root t_) then (t, ts) else (t_, t::ts_)
let deleteMin ts =
  let (Node(_, x, xs, ts1), ts2) = removeMinTree ts in
  let rec insertAll = function | ([], ts) -> ts
                               | (x::xs, ts) -> insertAll(xs, (insert x ts)) in
  insertAll(xs, (merge (List.rev ts1) ts2))

(********************************)
type textt = {
    title: string;
    name: string;
} [@@bs.deriving abstract]

type js_tree = {
    text: textt;
    children: js_tree list
} [@@bs.deriving abstract]

(* buggy, the compiler transforms [] into 0 *)
let rec js_of_tree = function Node(r, x, xs, c) ->
  js_tree
    ~text:(textt 
             ~title:(string_of_int x)
             ~name:(Printf.sprintf "rank=%d aux=[%s]" r (String.concat "," (List.map string_of_int xs))))
    ~children:(List.map js_of_tree c)

let js_of_heap  = List.map js_of_tree

let rec json_of_tree = function Node(r, x, xs, c) ->
  Printf.sprintf "{\"rank\": %d, \"text\": {\"title\": \"%s\", \"name\": \"%s\"}, \"children\":[%s]}"
                 r
                 (string_of_int x)
                 (Printf.sprintf "rank=%d aux=[%s]" r (String.concat "," (List.map string_of_int xs)))
                 (String.concat "," (List.map json_of_tree c))


let json_of_heap ts  = "[" ^ (String.concat "," (List.map json_of_tree ts)) ^ "]"
