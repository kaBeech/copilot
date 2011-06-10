--------------------------------------------------------------------------------
-- Copyright © 2011 National Institute of Aerospace / Galois, Inc.
--------------------------------------------------------------------------------

-- |

{-# LANGUAGE RebindableSyntax #-}

module Main where

import Prelude ()
import Copilot.Language
import Copilot.Language.Prelude hiding (even)
import Copilot.Language.Reify (reify)
import Copilot.Compile.C99 (compile)

--------------------------------------------------------------------------------

--
-- Some utility functions:
--

imply :: Bool -> Bool -> Bool
imply p q = not p || q

flipflop :: Stream Bool -> Stream Bool
flipflop x = y
  where
    y = [False] ++ if x then not y else y

counter :: (Num a, Typed a) => Stream Bool -> Stream a
counter reset = y
  where
    zy = [0] ++ y
    y  = if reset then 0 else zy + 1

booleans :: Stream Bool
booleans = [True, True, False] ++ booleans

fib :: Stream Word64
fib = [1, 1] ++ fib + drop 1 fib

sumExterns :: Stream Word64
sumExterns =
  let
    e1 = extern "e1"
    e2 = extern "e2"
  in
    e1 + e2

--------------------------------------------------------------------------------

--
-- An example of a complete copilot specification.
--

-- A specification:
spec :: Spec ()
spec =
  do
    -- A trigger with two arguments:
    trigger "f" booleans
      [ triggerArg fib
      , triggerArg sumExterns ]

    -- A trigger with a single argument:
    trigger "g" (flipflop booleans)
      [ triggerArg (sumExterns + counter false + 25) ]

    -- A trigger with a single argument:
    trigger "h" (extern "e3" /= fib)
      [ triggerArg (0 :: Stream Int8) ]

-- Some infinite lists for simulating external variables:
e1, e2, e3 :: [Word64]
e1 = [0..]
e2 = 5 : 4 : e2
e3 = [1, 1] ++ zipWith (+) e3 (drop 1 e3)

main :: IO ()
main =
  do
    putStrLn "PrettyPrinter:"
    putStrLn ""
    prettyPrint spec
    putStrLn ""
    putStrLn ""
    putStrLn "Interpreter:"
    putStrLn ""
    interpret 100 [input "e1" e1, input "e2" e2, input "e3" e3] spec

--------------------------------------------------------------------------------