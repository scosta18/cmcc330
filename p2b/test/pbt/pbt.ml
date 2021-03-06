open OUnit2
open QCheck
open P2b.Data
open P2b.Higher

(* Tests for count_occ *)
let test_count_occ = Test.make
 ~name:"test_count_occ"
 ~count:1000
 (int)
 (fun n->
   let l1 = Gen.generate1 (list (int_range (min_int+1) (n-1))).gen in
   let l2 = Gen.generate1 (list (int_range (n+1) (max_int-1))).gen in
   let l3 = Gen.generate1 (list (always n)).gen in
   let lst = l1@l2@l3 in
   let l = Gen.generate1 (Gen.shuffle_l lst) in 
   count_occ l n = List.length l3 
)
(* an arbitrary that list, an item, and count of the item in the list *)
let arb_occur =
  make (
      let open Gen in
      small_int >>=
        (fun n -> list (int_range min_int (n-1)) >>=
                    (fun l1 -> list (int_range (n+1) max_int) >>=
                                 (fun l2 -> list (return n) >>=
                                              fun l3 ->
                                              let a = shuffle_l (l1 @  l2 @ l3) in
                                              let b = return (List.length l3) in
                                              triple a b (return n)

    ))))
  
let test_count_occ2 =
  Test.make
 ~name:"test_count_occ2"
 ~count:1000
 (arb_occur)
 (fun (lst, count, item) -> count_occ lst item = count )
;;

let test_count_occ_out_len = 
  Test.make
  ~name:"test_count_occ_out_len"
  ~count:1000
  (small_int)
  (fun x ->
    let lst = Gen.generate ~n:x (Gen.small_int) in
    count_occ lst x <= List.length lst
  )

let test_count_occ_target_in_lst = 
  Test.make
  ~name:"test_count_occ_target_in_lst"
  ~count:1000
  (small_int)
  (fun x ->
    let lst = Gen.generate ~n:10 (Gen.small_int) in
    let lst = lst@[x] in
    count_occ lst x > 0
  )

let test_count_occ_reversed_same = 
  Test.make
  ~name:"test_count_occ_reversed_same"
  ~count:1000
  (small_int)
  (fun x ->
    let lst = Gen.generate ~n:x (Gen.small_int) in
    count_occ lst x = count_occ (List.rev lst) x
  )

(* Tests for uniq *)
let test_uniq_out_len = 
  Test.make
  ~name:"test_uniq_out_len"
  ~count:1000
  (small_int)
  (fun x ->
    let lst = Gen.generate ~n:x (Gen.small_int) in
    List.length (uniq lst) <= List.length lst
  )

let test_uniq_reversed_same_len = 
  Test.make
  ~name:"test_uniq_reversed_same"
  ~count:1000
  (list small_int)
  (fun x ->
    List.length (uniq x) = List.length (uniq (List.rev x))
  )

(* Testing assoc_list *)
let test_assoc_list_out_len = 
  Test.make
  ~name:"test_assoc_list_out_len"
  ~count:1000
  (list small_int)
  (fun x ->
    List.length (assoc_list x) <= List.length x
  )

let test_assoc_list_len_same_uniq = 
  Test.make
  ~name:"test_assoc_list_len_same_uniq"
  ~count:1000
  (list small_int)
  (fun x ->
    List.length (assoc_list x) = List.length (uniq x)
  )

(* Testing 3WST *)
let test_int_insert_size_should_inc = 
  Test.make
  ~name:"test_int_insert_size_should_inc"
  ~count:1000
  (small_int)
  (fun x ->
    let t0 = IntLeaf in
    let t1 = int_insert x t0 in
    int_size t1 > int_size t0
  )

let test_int_insert_twice_size_same = 
  Test.make
  ~name:"test_int_insert_twice_size_same"
  ~count:1000
  (small_int)
  (fun x ->
    let t0 = IntLeaf in
    let t1 = int_insert x t0 in
    let t2 = int_insert x t1 in
    int_size t2 = int_size t1
  )

let test_int_mem_after_inserting =
  Test.make
  ~name:"test_int_mem_after_inserting "
  ~count:1000
  (small_int)
  (fun x ->
    let t0 = IntLeaf in
    let t1 = int_insert x t0 in
    int_mem x t1
  )

let test_int_size_inc = 
  Test.make
  ~name:"test_int_size_inc "
  ~count:1000
  (small_int)
  (fun x ->
    let t0 = IntLeaf in
    int_size t0 < int_size (int_insert x t0)
  )

let test_int_max_inc = 
  Test.make
  ~name:"test_int_max_inc"
  ~count:1000
  (int_range 2 2)
  (fun x ->
    let lst = Gen.generate ~n:x (Gen.small_int) in
    let (max, min) = match lst with
      | [a;b] when a >= b -> (a, b)
      | [a;b] -> (b, a)
      | _ -> print_string "This should never happen."; (-1, -1) in
    
    let t0 = IntLeaf in
    let t1 = int_insert min t0 in
    let t2 = int_insert max t1 in
    int_max t2 >= int_max t1
  )

let suite =
  "public" >::: [
    QCheck_runner.to_ounit2_test test_count_occ;
    QCheck_runner.to_ounit2_test test_count_occ_out_len;
    QCheck_runner.to_ounit2_test test_count_occ_target_in_lst;
    QCheck_runner.to_ounit2_test test_count_occ_reversed_same; 
    QCheck_runner.to_ounit2_test test_uniq_out_len; 
    QCheck_runner.to_ounit2_test test_uniq_reversed_same_len; 
    QCheck_runner.to_ounit2_test test_assoc_list_out_len; 
    QCheck_runner.to_ounit2_test test_assoc_list_len_same_uniq; 
    QCheck_runner.to_ounit2_test test_int_insert_size_should_inc;
    QCheck_runner.to_ounit2_test test_int_insert_twice_size_same; 
    QCheck_runner.to_ounit2_test test_int_mem_after_inserting; 
    QCheck_runner.to_ounit2_test test_int_size_inc; 
    QCheck_runner.to_ounit2_test test_int_max_inc; 
  ]

let _ = run_test_tt_main suite
