module Context ( 
  empty
, nameToIndex
, indexToName
, addName
, pickFreshName
) where

import           Data.List (findIndex)
import qualified Data.HashSet as S

import           Types (Context (..))

empty :: Context
empty = Context []

nameToIndex :: Context -> String -> Either String Int
nameToIndex (Context ctx) name = case findIndex (== name) ctx of
  Just index -> Right index
  Nothing -> Left $ "variable " ++ name ++ " is unbound"

indexToName :: Context -> Int -> String
indexToName (Context ctx) index = ctx !! index

addName :: Context -> String -> Context
addName (Context ctx) name = Context (name:ctx)

pickFreshName :: Context -> String -> (Context, String)
pickFreshName (Context ctx) name = (addName (Context ctx) freshName, freshName)
  where
    ctx' = S.fromList ctx
    freshName = if name `S.member` ctx' 
                  then go 1
                  else name
    go index = if fresh `S.member` ctx' then go (index + 1) else fresh
      where
        fresh = name ++ "_" ++ show index