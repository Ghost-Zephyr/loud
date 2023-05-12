module Loud ( write ) where

import Data.String ( fromString )
import Data.ByteString
import Foreign.Ptr
import Foreign.C

setup :: IO ()
setup = putStrLn "Fuck you!"

write :: IO Int
write = do
  let msg = "Hello, Haskell!\n"
  useAsCStringLen (fromString msg :: ByteString) sus_write

sus_write :: CStringLen -> IO Int
sus_write (cstr, len) = _syscall 1 1 (minusPtr cstr nullPtr) len 0 0

foreign import ccall "syscall"
  _syscall :: Int -> Int -> Int -> Int -> Int -> Int -> IO Int

foreign export ccall setup :: IO ()
