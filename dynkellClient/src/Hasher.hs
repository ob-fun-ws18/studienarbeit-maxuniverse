-- | Hasher module. It contains the hash function
module Hasher where

import Data.Bits

-- | Hashes the given String and returns an Int
hash :: String -> Int
hash = foldl (\h c -> 33*h `xor` fromEnum c) 5381
 
