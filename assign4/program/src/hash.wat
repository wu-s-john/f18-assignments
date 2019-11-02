(module
  (memory 1)
  (export "mem" (memory 0))

  ;; Stack-based Adler32 hash implementation.
  (func $adler32 (param $address i32) (param $len i32) (result i32)
    (local $a i32) (local $b i32) (local $i i32)

    ;; YOUR CODE GOES HERE
    (i32.const 0)
    )
  (export "adler32" (func $adler32))

  (i32.const 65535)



  ;; Tree-based Adler32 hash implementation.
  (func $adler32v2 (param $address i32) (param $len i32) (result i32)
    (local $a i32) (local $b i32) (local $i i32)
    (i32.const 1)
    (set_local $a)
    (i32.const 0)
    (set_local $b)
    (i32.const 0)
    (set_local $i)

    (block $incr_loop_break 
    
      (loop $incr_loop
        ;; breaking the for loop
        (get_local $len)
        (get_local $i)
        (i32.eq)
        (br_if $incr_loop_break)
        ;; compute the offset
        (get_local $i)
        (i32.const 8)
        (i32.mul)
        
        (get_local $address)
        (i32.shl)
        (i32.const 255)
        (i32.and)
        
        (get_local $a)
        (i32.add)
        (set_local $a)
        (i32.const 65535)
        (get_local $a)
        (i32.rem_u)
        (set_local $a)
        
        (i32.const 65535)
        (get_local $a)
        (get_local $b)
        (i32.add)
        (i32.rem_u)
        (set_local $b)






      






      
      )
    )


    ;; YOUR CODE GOES HERE
    (get_local $a )
    )

  (export "adler32v2" (func $adler32v2))

  ;; Initialize memory allocator. Creates the initial block assuming memory starts with
  ;; 1 page.
  (func $alloc_init
    (i32.store (i32.const 0) (i32.const 65528))
    (i32.store (i32.const 4) (i32.const 1)))
  (export "alloc_init" (func $alloc_init))

  ;; Frees a memory block by setting the free bit to 1.
  (func $free (param $address i32)
    (i32.store
      (i32.sub (get_local $address) (i32.const 4))
      (i32.const 1)))
  (export "free" (func $free))

  (func $alloc (param $len i32) (result i32)
    ;; YOUR CODE GOES HERE
    (unreachable)
    )
  (export "alloc" (func $alloc))

  )
