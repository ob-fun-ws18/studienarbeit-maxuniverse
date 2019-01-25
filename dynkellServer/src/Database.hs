{-# LANGUAGE OverloadedStrings #-}
module Database(query,update)where

import Database.HDBC.MySQL
import Database.HDBC

{- | Define a function that takes an integer representing the maximum
id value to look up.  Will fetch all matching rows from the test database
and print them to the screen in a friendly format. -}
query :: String -> IO [[SqlValue]]
query sql = 
    do -- Connect to the database
         conn <- connectMySQL defaultMySQLConnectInfo {
                       mysqlHost     = "127.0.0.1",
                       mysqlDatabase = "dynkell",
                       mysqlUser     = "root",
                       mysqlPassword = "metallica"
                    }

         rows <- quickQuery' conn sql []
         disconnect conn
         return rows

-- | Execute the given command as string then commit the changes to the database
update :: String -> IO Integer
update sql =
    do
         conn <- connectMySQL defaultMySQLConnectInfo {
                       mysqlHost     = "127.0.0.1",
                       mysqlDatabase = "dynkell",
                       mysqlUser     = "root",
                       mysqlPassword = "metallica"
                    }
  
         rows <- run conn sql []
         commit conn
         disconnect conn
         return rows
