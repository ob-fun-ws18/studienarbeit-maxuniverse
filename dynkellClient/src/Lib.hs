{-# LANGUAGE OverloadedStrings #-}


-- | DynKell Client Module
-- | Used to start a DynKell Client.
-- | Authors: Maximilian Schmitz and Beniamin Bratulescu
module Lib(runClient) where

import Control.Concurrent  as CC  (forkIO, threadDelay, killThread)
import qualified Data.ByteString.Char8 as C
import Network.Socket 
import Network.Socket.ByteString as B
import Data.IORef
import Control.Monad            (forever)
import System.Cron.Schedule

-- | Please change here the address of the dynkell server.
address = "127.0.0.1"
port = "7000"

-- | Waits 3 seconds for a response from the server. If the server does not respond in the time, it retuns 0 and 1 otherwise
receiveDatagram :: IO Int
receiveDatagram = do 
  ack <- newIORef (0 :: Int) -- variable to check is the server has responded
  addrinfos <- getAddrInfo Nothing (Just "127.0.0.1") (Just "7001") -- Listen on localhost:7001
  let serveraddr = head addrinfos
  sock <- socket (addrFamily serveraddr) Datagram defaultProtocol
  bind sock (addrAddress serveraddr)
  id <- CC.forkIO ( do -- Create a new thread to listen for a response
    (msg, addr) <- B.recvFrom sock 1024
    print msg
    writeIORef ack 1
    )
  threadDelay 3000000 -- Wait 3 seconds for the thread
  close sock
  killThread id -- Kill the created thread
  readIORef ack

-- | Sends a UDP Datagram to the given address on the given port with the domain and hashed username and password
sendMessage :: String -> String -> String -> String -> IO ()
sendMessage address port domain hashed = do
  addrinfos <- getAddrInfo Nothing (Just address) (Just port)
  let serveraddr = head addrinfos
  sock <- socket (addrFamily serveraddr) Datagram defaultProtocol
  connect sock (addrAddress serveraddr)
  B.sendAll sock $ C.pack $ domain ++ "||" ++ hashed -- The separator between domain and the hashed value is "||"
  close sock


-- | Starts a cronjob in a new thread, then waits forever.
-- | First sring is the domain and the second one is the hashed string of the username and password
runClient :: String -> String -> IO ()
runClient domain hashed = do
  tid <- execSchedule $ addJob (sendName domain hashed) "* * * * *" -- Cronjob every minute
  print tid
  forever (threadDelay maxBound)

-- | Sends the domanin name to the server. If the server does not respond it tries 3 more times then gives up.
sendName :: String -> String -> IO ()
sendName domain hashed = do
  sendMessage address port domain hashed
  result <- receiveDatagram
  if result == 0 then do
      print "Could not reach the server retrying (1)..."
      sendMessage address port domain hashed
      result <- receiveDatagram
      if result == 0 then do
        print "Could not reach the server retrying (2)..."
        sendMessage address port domain hashed
        result <- receiveDatagram
        if result == 0 then do
          print "Could not reach the server retrying (3)..."
          sendMessage address port domain hashed
          result <- receiveDatagram
          if result == 0 then
            print "Server could not be reached"
            else
              return ()
          else
            return ()
        else
          return ()
      else
        return ()
