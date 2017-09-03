{-# LANGUAGE TypeOperators
           , FlexibleContexts #-}
module SMTP where

import Control.Monad
import Test.QuickCheck

import SessionCheck

-- Approximations
type Domain = String
type ForwardPath = String
type ReversePath = ForwardPath 

data SMTPCommand = HELO Domain
                 | MAIL_FROM ReversePath
                 | RCPT_TO ForwardPath
                 | DATA
                 | RSET
                 | SEND_FROM ReversePath
                 | SOML_FROM ReversePath
                 | SAML_FROM ReversePath
                 | VRFY String
                 | EXPN String
                 | HELP (Maybe String)
                 | NOOP
                 | QUIT
                 | TURN
                 deriving (Ord, Eq, Show)

data SMTPReply = R500 
               | R501
               | R502
               | R503
               | R504
               | R211
               | R214
               | R220 Domain
               | R221 Domain
               | R421 Domain
               | R250 
               | R251 ForwardPath
               | R450
               | R550
               | R451
               | R551 ForwardPath
               | R452
               | R552
               | R553
               | R354
               | R554
               deriving (Ord, Eq, Show)

heloMessage :: Predicate SMTPCommand 
heloMessage = Predicate { apply = \c -> case c of
                                          HELO _ -> True
                                          _      -> False
                        , satisfies = HELO <$> arbitrary
                        , shrunk    = \(HELO d) -> elements (HELO <$> shrink d)
                        , name      = "heloMessage" }

mailMessage :: Predicate SMTPCommand
mailMessage = Predicate { apply = \c -> case c of
                                          MAIL_FROM _ -> True
                                          _           -> False
                        , satisfies = MAIL_FROM <$> arbitrary
                        , shrunk    = \(MAIL_FROM d) -> elements (MAIL_FROM <$> shrink d)
                        , name      = "mailMessage" }

dataMessage :: Predicate SMTPCommand
dataMessage = (is DATA) { name = "dataMessage" }

endOfMail :: Predicate String
endOfMail = Predicate { apply     = (==".")
                      , satisfies = return "."
                      , shrunk    = \_ -> return []
                      , name      = "endOfMail" }
