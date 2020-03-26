module Eg024BrandsCreatingHelper
  def language_list
    languages = [ ['Arabic', 'ar'],[ 'Armenian', 'hy'] , ['Bahasa Indonesia', 'id' ], ['Bahasa Malay', 'ms'], ['Bulgarian', 'bg'],
                ['Chinese Simplified', 'zh_CN'], ['Chinese Traditional', 'zh_TW'], ['Croatian', 'hr'], ['Czech', 'cs'],
                ['Danish', 'da'], ['Dutch', 'nl'], ['English UK', 'en_GB'], ['English US', 'en' ], ['Estonian', 'et'], ['Farsi', 'fa'],
                ['Hindi', 'hi'], ['Hungarian', 'hu'], ['Italian', 'it'], ['Japanese', 'ja'], ['Korean', 'ko'], ['Latvian', 'lv'],
                ['Lithuanian', 'lt'], ['Norwegian', 'no'], ['Polish', 'pl'], ['Portuguese', 'pt'], ['Portuguese Brasil', 'pt_BR'], ['Romanian', 'ro'],
                ['Russian', 'ru'], ['Serbian', 'sr'], ['Slovak', 'sk'], ['Slovenian', 'sl'], ['Spanish', 'es'], ['Spanish Latin America', 'es_MX'],
                ['Swedish', 'sv'], ['Thai', 'th'], ['Turkish', 'tr'], ['Ukranian', 'uk'], ['Vietnamese', 'vi'] ]
    array     = languages.map{ |key, value| [key, value] }
    options_for_select(array)
  end
end
