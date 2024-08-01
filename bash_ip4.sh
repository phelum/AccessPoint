#!/bin/bash     # Put here so fte knows it's a script file

#   This file is sourced not executed.
#   All these functions get added to the environment.

    #   param:      $1 = x.x.x.x netmask
    #   returns:    0xhhhhhhhh string

function IP4_addr2word ()
  {
    local   MASK=${1//./ }
    local   HEX=0
    local   WORD

    for WORD in ${MASK} ; do
      (( HEX = HEX * 256 + WORD ))
    done

    printf '0x%x' ${HEX}
  }


    #   param:      $1 = 0xhhhhhhhh string
    #   returns:    count of leading 1 bits

function IP4_word2len ()
  {
    local   WORD=$1
    local   HEX
    local   LEN=0

    (( HEX = WORD ))
    while (( HEX & (1 << (31 - LEN)) )) ; do
      (( LEN++ ))
    done

    printf '%d' ${LEN}
  }


    #   param:      $1 = count of leading 1 bits
    #   returns:    x.x.x.x netmask

function IP4_len2mask ()
  {
    local   LEN=$1
    local   X
    local   OCTET[4]
    local   INDEX
    local   MASK

    (( X = 0xffffffff << (32 - LEN) ))
    for INDEX in 3 2 1 0 ; do
      (( OCTET[${INDEX}] = X & 0xFF ))
      (( X >>= 8 ))
    done

    printf '%d.%d.%d.%d\n' ${OCTET[@]}
  }


    #   param:      $1 = x.x.x.x netmask
    #   returns:    count of leading 1 bits

function IP4_mask2len ()
  {
    local   MASK=$1

    printf $(IP4_word2len $(IP4_addr2word ${MASK}))
  }


    #   param:      $1 = x.x.x.x/n
    #   returns:    x.x.x.x

function IP4_cidr2addr ()
  {
    local   CIDR=$1
    local   ADDR

    printf ${CIDR%/*}
  }


    #   param:      $1 = x.x.x.x/n
    #   returns:    n

function IP4_cidr2len ()
  {
    local   CIDR=$1
    local   LEN

    LEN=${CIDR#*/}
    [ "${LEN}" = "${CIDR}" ] && LEN=32

    printf ${LEN}
  }


    #   param:      $1 = x.x.x.x/n
    #   returns:    netmask for range

function IP4_cidr2mask ()
  {
    local   CIDR=$1
    local   LEN
    local   MASK

    LEN=$(IP4_cidr2len ${CIDR})
    MASK=$(IP4_len2mask ${LEN})

    printf ${MASK}
  }


    #   param:      $1 = x.x.x.x/n
    #   optional:   $2 = offset to add to addr
    #   returns:    first x.x.x.x for range

function IP4_cidr2first ()
  {
    local   CIDR=$1
    local   ADDR
    local   LEN
    local   MASK
    local   INDEX
    local   OCTET[4]

    ADDR=$(IP4_addr2word $(IP4_cidr2addr ${CIDR}))
    LEN=$(IP4_cidr2len ${CIDR})
    (( INDEX = 32 - LEN ))
    (( MASK = 0xffffffff << INDEX ))
    (( ADDR &= MASK ))

    for INDEX in 3 2 1 0 ; do
      (( OCTET[${INDEX}] = ADDR & 0xFF ))
      (( ADDR >>= 8 ))
    done
    [ $# = 2 ] && (( OCTET[3] += $2 ))

    printf '%d.%d.%d.%d\n' ${OCTET[@]}
  }


    #   param:      $1 = x.x.x.x/n
    #   optional:   $2 = offset to subtract from addr
    #   returns:    last x.x.x.x for range

function IP4_cidr2last ()
  {
    local   CIDR=$1
    local   ADDR
    local   LEN
    local   MASK
    local   INDEX
    local   OCTET[4]

    ADDR=$(IP4_addr2word $(IP4_cidr2addr ${CIDR}))
    LEN=$(IP4_cidr2len ${CIDR})
    (( MASK = 0xffffffff >> LEN ))
    (( ADDR |= MASK ))

    for INDEX in 3 2 1 0 ; do
      (( OCTET[${INDEX}] = ADDR & 0xFF ))
      (( ADDR >>= 8 ))
    done
    [ $# = 2 ] && (( OCTET[3] -= $2 ))

    printf '%d.%d.%d.%d\n' ${OCTET[@]}
  }


