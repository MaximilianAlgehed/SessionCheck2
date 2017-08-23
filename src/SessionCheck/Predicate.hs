{-# LANGUAGE TypeOperators #-}
module SessionCheck.Predicate where

import Test.QuickCheck
import Data.List

import SessionCheck.Classes

-- A representation of dualizable predicates 
data Predicate a =
  Predicate { apply     :: a -> Bool
            , satisfies :: Gen a
            , name      :: String }

-- Test if a `t` satisfies a predicate for `a`s when `a :< t`
test :: a :< t => Predicate a -> t -> Bool
test p t = maybe False id (apply p <$> prj t)

-- The predicate which accepts anything
anything :: Arbitrary a => Predicate a
anything = Predicate { apply     = const True
                     , satisfies = arbitrary
                     , name      = "anything" }

-- Accepts any `Int`
anyInt :: Predicate Int
anyInt = anything { name = "anyInt" }

-- Accepts any positive int
posInt :: Predicate Int
posInt = Predicate { apply     = (>0)
                   , satisfies = fmap ((+1) . abs) arbitrary
                   , name      = "posInt" }

-- Accepts any negative int
negInt :: Predicate Int
negInt = Predicate { apply     = (<0)
                   , satisfies = fmap (negate . (+1) . abs) arbitrary
                   , name      = "negInt" }

-- Accepts any non-negative int
nonNegInt :: Predicate Int
nonNegInt = Predicate { apply     = (>=0)
                      , satisfies = fmap abs arbitrary
                      , name      = "nonNegInt" }

-- Accepts anything in the range [p, q]
inRange :: (Ord a, Show a, Arbitrary a) => a -> a ->  Predicate a
inRange p q = Predicate { apply     = \a -> p <= a && a <= q
                        , satisfies = arbitrary `suchThat` (apply (inRange p q))
                        , name      = "inRange " ++ show p ++ " " ++ show q }

-- Accepts any `Double`
anyDouble :: Predicate Int
anyDouble = anything { name = "anyDouble" }

-- Accepts any `Dobule`
anyBool :: Predicate Int
anyBool = anything { name = "anyBool" }

-- Accepts any member of `as`
choiceOf :: (Eq a, Show a) => [a] -> Predicate a
choiceOf as = Predicate { apply     = flip elem as
                        , satisfies = elements as 
                        , name      = "choiceOf " ++ show as }

-- Accepts any permuation of `as`
permutationOf :: (Eq a, Show a) => [a] -> Predicate [a]
permutationOf as = Predicate { apply     = \as' -> elem as' (permutations as)
                             , satisfies = shuffle as
                             , name      = "permutationOf " ++ show as }

-- Accepts precisely `a`
is :: (Eq a, Show a) => a -> Predicate a
is a = Predicate { apply     = (a==)
                 , satisfies = return a
                 , name      = "is " ++ show a }
