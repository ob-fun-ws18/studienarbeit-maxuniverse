-- | Hasher Module for DynKell Server
-- | Author: Maximilian Schmitz
module Hasher where

import Data.Bits
-- | Hashes the given string and returns an integer value
hash :: String -> Int
hash = foldl (\h c -> 33*h `xor` fromEnum c) 5381
