(module
  (memory 1)
  (export "mem" (memory 0))

  ;; Stack-based Adler32 hash implementation.
  (func $adler32 (param $address i32) (param $len i32) (result i32)
    (local $a i32) (local $b i32) (local $i i32) (local $adler_constant i32)
    
    (i32.const 65535)
    (set_local $adler_constant)
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
        ;; data[index]
        (get_local $i)
        (get_local $address)
        (i32.add)
        (i32.load8_u)
        
        ;; (a + data[index])
        (get_local $a)
        (i32.add)
        ;; (a + data[index]) % MOD_ADLER;
        (get_local $adler_constant)
        (i32.rem_u)
        ;; a = (a + data[index]) % MOD_ADLER
        (set_local $a)
        
        (get_local $a)
        (get_local $b)
        (i32.add)
        (get_local $adler_constant)
        (i32.rem_u)
        (set_local $b)

        (get_local $i)
        (i32.const 1)
        (i32.add)
        (set_local $i)

        (br $incr_loop)      
      )
    )
      (get_local $b)
      (i32.const 16)
      (i32.shl)
      (get_local $a)
      (i32.or)

    )
  (export "adler32" (func $adler32))



  ;; Tree-based Adler32 hash implementation.
  (func $adler32v2 (param $address i32) (param $len i32) (result i32)
    (local $a i32) (local $b i32) (local $i i32) (local $adler_constant i32)
    
    
    (set_local $adler_constant 
      (i32.const 65535))
    
    (set_local $a 
      (i32.const 1)
    )
    
    (set_local $b
      (i32.const 0)
    )
        
    (set_local $i
      (i32.const 0)
    )

    (block $incr_loop_break 
    
      (loop $incr_loop
        ;; breaking the for loop
        
        (br_if $incr_loop_break
          (i32.eq
            (get_local $i)
            (get_local $len)
          )
        )
        
        ;; compute the offset
        ;; data[index]
        
        ;; a = (a + data[index])
        (i32.rem_u
          (i32.add
            (i32.load8_u
              (i32.add
                (get_local $i)
                (get_local $address)
              )
            )
            (get_local $a)
          )
          (get_local $adler_constant)
        )
      
        ;; a = (a + data[index]) % MOD_ADLER
        (set_local $a)
        
        (set_local $b
        (i32.rem_u
          (i32.add
            (get_local $a)
            (get_local $b)
          )
          (get_local $adler_constant)
        )
        )

        (set_local $i
          (i32.add
            (get_local $i)
            (i32.const 1)
          )
        )

        (br $incr_loop)      
      )
    )
      (get_local $b)
      (i32.const 16)
      (i32.shl)
      (get_local $a)
      (i32.or)

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

  ;; (global.set $PAGE_SI)

  (global $PAGE_SIZE i32
    (i32.const 65536)
  )

  (func $propose_block 
    (param $curr_length_location i32) (param $curr_length i32) (param $new_block_length i32) (result i32) (local $free_location i32) 
    (local $new_block_length_location i32) 
    (local $new_block_length_with_offset i32)

    (
        ;; No matter what, you will set the location of the current block's free flag to zero
        i32.store
        (i32.const 0)
          (i32.add
            (i32.const 4)
            (get_local $curr_length_location)
          )
    )
    (set_local $new_block_length_with_offset
      (i32.add
        (get_local $new_block_length)
        (i32.const 8)
      )
    )
    
    (block $condtional_statement_break
      (block $goto_true_statement
        (i32.ge_s
          (get_local $new_block_length_with_offset)
          (get_local $curr_length)
        )
        (br_if $condtional_statement_break)
        ;; Update the current block's length as the new block length
        (i32.store
          (get_local $new_block_length)
          (get_local $curr_length_location)
        )
        ;; Create the new block
        (set_local
          $new_block_length_location
          (i32.add
            (i32.add
              (get_local $curr_length_location)
              (get_local $curr_length)
            )
            (i32.const 8)
          )
        )

        ;; Store the new length
        (i32.store
          (i32.sub
            (get_local $new_block_length_with_offset)
            (get_local $curr_length_location)
          )
          (get_local $new_block_length_location)
        )

        ;; store the new flag
        (i32.store
          (i32.gt_s 
            (get_local $new_block_length_with_offset)
            (get_local $curr_length) 
            )
          (i32.add
            (i32.const 4)
            (get_local $new_block_length_location)
          )
        )
      )
      
      ;; This is the true statement
    )

    (i32.add
      (i32.const 8)
      (get_local $curr_length_location)
    )
    
      
  )

  (func $alloc (param $len i32) (result i32) 
    (local $addr i32) (local $curr_len i32) (local $curr_flag_loc i32)

    (block $alloc_loop_break
      (block $death_loop
        (loop $alloc_loop
          (br_if $death_loop
            (get_global $PAGE_SIZE)
            (get_local $addr)
            (i32.eq)
          )
          ;; Get block length
          (set_local $curr_len
            (i32.load 
              (get_local $addr)
            )
          )

          
          
          (set_local $curr_flag_loc
            (i32.add
              (get_local $addr)
              (i32.const 4)
            )
          )

          (block $false_statement
            (block $true_statement
                (i32.and 
                  (i32.eq
                    (i32.load 
                      ;; Get block flag
                      (get_local  $curr_flag_loc)
                    )
                    (i32.const 1)
                  )
                  (i32.gt_s
                      ;; There is an
                      (i32.add
                        (get_local $len)
                        (i32.const 8)
                      )
                    (get_local $curr_len)
                  )
                )
                ;; You enter the third staement
                (br_if $true_statement)

                (set_local $addr
                  (i32.add 
                    (i32.add
                      (get_local $addr)
                      (i32.const 8)
                    )
                    (get_local $curr_len)
                  )
                )

                ;; fill in false statement here
                (br $false_statement)
            )
            (i32.store 
              (i32.const 0)
              (get_local $curr_flag_loc)

            )
          )



          ;; TODO: You need to jump to the next memory (block length + 2 * 4 bytes)
          (set_local $addr
            (i32.add
              (get_local $addr)
              (i32.const 1)
            )
          )
          (br $alloc_loop)
        )
      )
      (unreachable)
    )


    ;; YOUR CODE GOES HERE
    (unreachable)
    )
  (export "alloc" (func $alloc))

  )
