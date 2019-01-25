{-
Main Module of the DynKell Client
Imports all the DynKell Modules then starts the client with the provided Data
Authors: Beniamin Bratulescu and Maximillian Schmitz
-}
module Main where

import Lib
import Hasher
import System.Environment   
import Data.List

-- | Username, pass and domain to be sent
username = "test"
password = "test123"
domain = "example.com"

-- | Hashes the password and the username, then starts the DynKell client.
main :: IO ()
main = do
  let hashedPw = hash password
  let hashed = hash $ username ++ show hashedPw
  runClient domain $ show hashed
