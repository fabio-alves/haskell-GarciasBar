{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Bebida where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)

formBebida :: Form Bebida
formBebida = renderBootstrap3 BootstrapBasicForm $ Bebida
  <$> areq textField "Nome: " Nothing
  <*> areq textField "Comentario: " Nothing
  <*> areq doubleField "Valor: " Nothing

getBebidaR :: Handler Html
getBebidaR = do 
  (formWidget, _) <- generateFormPost formBebida
  defaultLayout $ do
    [whamlet|
        <form action=@{BebidaR} method=post>
          ^{formWidget}
          <input type="submit" value="Enviar">
    |]

postBebidaR :: Handler Html
postBebidaR = do 
    ((result, _), _) <- runFormPost formBebida
    case result of
      FormSuccess bebida -> do  
        pid <- runDB $ insert bebida
        redirect (DescR pid) 
      _ -> redirect HomeR

getDescR :: BebidaId -> Handler Html
getDescR pid = do
    bebida <- runDB $ get404 pid 
    defaultLayout $ do
      [whamlet|
        <ul>
          <li> Nome: #{bebidaNome bebida}
          <li> Comentario: #{bebidaComentario bebida}
          <li> Valor: #{bebidaValor bebida}
    |]
