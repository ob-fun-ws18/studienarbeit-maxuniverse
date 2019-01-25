{-# LANGUAGE OverloadedStrings #-}
-- | Lib Module for Dynkell Server
-- | Authors: Maximilian Schmitz and Beniamin Bratulescu
module Lib
    ( runUDPServer
    ) where
import Database as DB
import Hasher as HS
import Control.Concurrent       (threadDelay)
import Control.Monad             (forever)
import qualified Data.ByteString.Char8 as C
import Network.Socket as NS 
import Network.Socket.ByteString as B
import Data.List.Split
import Database.HDBC as HDBC


accessFile = "/var/log/dynkell/dynkell-access.log"
errorFile = "/var/log/dynkell/dynkell-error.log"

-- | Listen on port 7000 for UDP datagrams and print the address of the sender
-- | It also checks the database and if everything is ok then it changes the DB entry 
runUDPServer :: IO ()
runUDPServer = do
  addrinfos <- getAddrInfo Nothing (Just "127.0.0.1") (Just "7000")
  let serveraddr = head addrinfos 
  sock <- socket (addrFamily serveraddr) Datagram defaultProtocol
  bind sock (addrAddress serveraddr)
  forever (do -- Listen forever for UDP datagrams
    (msg, addr) <- B.recvFrom sock 1024
    putStrLn $ "From " ++ show addr ++ ": " ++ show msg
    putStrLn $ "Address: " ++ getAddr addr
    if msg /= "" then checkDBEntries (show msg) (getAddr addr)
                 else sendMessage (getAddr addr) "7001" "401 - Unauthorised"
          )

-- | Checks the database entries. It first reads the data, checks it and if everything is ok then it writes the new address
checkDBEntries :: String -> String -> IO ()
checkDBEntries message address = do
  let cDomain = head (splitOn "||" message)
  let cHashed = splitOn "||" message !! 1
  result <- DB.query $ "select * from users where domain='" ++ tail cDomain ++ "'"
  let dUser = HDBC.fromSql $ head result !! 1
  let dPw = HDBC.fromSql $ head result !! 2
  let dHashed = HS.hash $ dUser ++ "" ++ dPw
  if show dHashed == init cHashed then do
                                             update <- DB.update $ "update records set content='" ++ address ++ "' where name='" ++ tail cDomain ++ "' and type='A'"
                                             if update >= 0 then do appendFile accessFile ("Update successful (" ++ address ++ ")\n")
                                                            else appendFile errorFile "An error occured!\n"
                                             print $ "Entries updated: " ++ show update
                                             sendMessage address "7001" address
                                      else sendMessage address "7001" "401 - Unauthorised"


-- | Gets only the address from a given socket address. Format is as following: "address:port"
getAddr :: SockAddr -> String 
getAddr address = head ( splitOn ":" (show address) ) -- Print only the first element of the list, in this case, the address

-- | Sends a message back too the client
sendMessage :: String -> String -> String -> IO ()
sendMessage address port message = do
  addrinfos <- getAddrInfo Nothing (Just address) (Just port)
  let serveraddr = head addrinfos
  sock <- socket (addrFamily serveraddr) Datagram defaultProtocol
  NS.connect sock (addrAddress serveraddr)
  B.sendAll sock $ C.pack message
  NS.close sock