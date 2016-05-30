{

module Lexer (
  scanTokens
) where

import Data.Word (Word8)
import TAPL.Helper (utf8Encode)
import Types

}

tokens :-
  $white+                ;
  \(                     { \_ -> TokenLBracket }
  \)                     { \_ -> TokenRBracket }
  \.                     { \_ -> TokenDot }
  \:                     { \_ -> TokenColon }
  \->                    { \_ -> TokenArrow }
  [a-zA-Z]+              { \s -> case lookupKeyword s of
                                   Just t -> t
                                   Nothing -> TokenVar s }
  [a-z][a-zA-z0-9\_\']*  { \s -> TokenVar s }

{

type AlexInput = (Char,     -- previous char
                  [Word8],  -- pending bytes on current char
                  String)   -- current input string

type AlexAction = String -> Token

alexInputPrevChar :: AlexInput -> Char
alexInputPrevChar (c, _, _) = c

alexGetByte :: AlexInput -> Maybe (Word8, AlexInput)
alexGetByte (c, (b:bs), s) = Just (b, (c, bs, s))
alexGetByte (_, [], []) = Nothing
alexGetByte (_, [], (c:s)) = let (b:bs) = utf8Encode c
                              in Just (b, (c, bs, s))

alexFail :: a
alexFail = error "lexical error"

scanTokens :: String -> [Token]
scanTokens str = go ('\n', [], str)
  where
    go inp@(_, _, input) = case alexScan inp 0 of
      AlexEOF -> []
      AlexError _ -> alexFail
      AlexSkip inp' _ -> go inp'
      AlexToken inp' length action -> action (take length input) : go inp'

lookupKeyword :: String -> Maybe Token
lookupKeyword kw = lookup kw keywords
  where
    keywords = [ ("if", TokenIf)
               , ("then", TokenThen)
               , ("else", TokenElse)
               , ("true", TokenTrue)
               , ("false", TokenFalse)
               , ("Bool", TokenBool)
               , ("lambda", TokenLambda)
               ]

}