module Eg024BrandsCreatingHelper
  def language_list
    languages = [%w[Arabic ar], %w[Armenian hy], ['Bahasa Indonesia', 'id'], ['Bahasa Malay', 'ms'], %w[Bulgarian bg],
                 ['Chinese Simplified', 'zh_CN'], ['Chinese Traditional', 'zh_TW'], %w[Croatian hr], %w[Czech cs],
                 %w[Danish da], %w[Dutch nl], ['English UK', 'en_GB'], ['English US', 'en'], %w[Estonian et], %w[Farsi fa],
                 %w[Hindi hi], %w[Hungarian hu], %w[Italian it], %w[Japanese ja], %w[Korean ko], %w[Latvian lv],
                 %w[Lithuanian lt], %w[Norwegian no], %w[Polish pl], %w[Portuguese pt], ['Portuguese Brasil', 'pt_BR'], %w[Romanian ro],
                 %w[Russian ru], %w[Serbian sr], %w[Slovak sk], %w[Slovenian sl], %w[Spanish es], ['Spanish Latin America', 'es_MX'],
                 %w[Swedish sv], %w[Thai th], %w[Turkish tr], %w[Ukranian uk], %w[Vietnamese vi]]
    array     = languages.map { |key, value| [key, value] }
    options_for_select(array)
  end
end
