-- stolen from Haddock's Util.hs and Doc.hs
module Distribution.Server.Pages.Package.HaddockHtml where

import Data.Maybe               (fromMaybe)
import Text.XHtml.Strict        hiding (p)
import Network.URI              (escapeURIString, isUnreserved)

import Documentation.Haddock.Types


-- C.f. haddock-api's "Haddock.Backends.Xhtml.DocMarkup"
htmlMarkup :: DocMarkupH mod String Html
htmlMarkup = Markup {
  markupEmpty         = noHtml,
  markupString        = toHtml,
  markupParagraph     = paragraph,
  markupAppend        = (+++),
  markupIdentifier    = thecode . toHtml . init . tail,
  markupIdentifierUnchecked = const (thecode $ toHtml "FIXME"), -- should never happen
  markupModule        = thecode . toHtml,
  markupWarning       = thediv ! [theclass "warning"],
  markupEmphasis      = emphasize,
  markupBold          = strong,
  markupMonospaced    = thecode,
  markupUnorderedList = unordList,
  markupOrderedList   = ordList,
  markupDefList       = defList,
  markupCodeBlock     = pre,
  markupHyperlink     = \(Hyperlink url mLabel) -> anchor ! [href url] << fromMaybe url mLabel,
  markupAName         = \aname -> namedAnchor aname << toHtml "",
  markupPic           = \(Picture uri mtitle) -> image ! ([src uri] ++ fromMaybe [] (return . title <$> mtitle)),
  markupMathInline    = \mathjax -> toHtml ("\\(" ++ mathjax ++ "\\)"),
  markupMathDisplay   = \mathjax -> toHtml ("\\[" ++ mathjax ++ "\\]"),
  markupProperty      = pre . toHtml,
  markupExample       = examplesToHtml,
  markupHeader        = \(Header l t) -> makeHeader l t
  }
  where
    makeHeader :: Int -> Html -> Html
    makeHeader 1 mkup = h2 mkup
    makeHeader 2 mkup = h3 mkup
    makeHeader 3 mkup = h4 mkup
    makeHeader 4 mkup = h5 mkup
    makeHeader 5 mkup = h6 mkup
    makeHeader 6 mkup = h6 mkup
    makeHeader l _ = error $ "Somehow got a header level `" ++ show l ++ "' in DocMarkup!"

    examplesToHtml l = pre (concatHtml $ map exampleToHtml l) ! [theclass "screen"]

    exampleToHtml (Example expression result) = htmlExample
      where
        htmlExample = htmlPrompt +++ htmlExpression +++ toHtml (unlines result)
        htmlPrompt = (thecode . toHtml $ ">>> ") ! [theclass "prompt"]
        htmlExpression = (strong . thecode . toHtml $ expression ++ "\n") ! [theclass "userinput"]

namedAnchor :: String -> Html -> Html
namedAnchor n = anchor ! [name (escapeStr n)]

escapeStr :: String -> String
escapeStr = escapeURIString isUnreserved
