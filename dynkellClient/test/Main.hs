module Main(main) where

import Test.Hspec
import Lib(runClient)
import System.Timeout


main :: IO ()
main = hspec $
    describe "client" $
        it "tries to send example.com to the server" $
            timeout 65000000 (runClient "example.com" "someHashedString") `shouldReturn` Nothing
