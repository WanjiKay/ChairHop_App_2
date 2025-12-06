RubyLLM.configure do |config|
<<<<<<< HEAD
  config.openai_api_key = ENV["OPENAI_API_KEY"]
=======
  # config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.openai_api_key = ENV["GITHUB_TOKEN"]
  config.openai_api_base = "https://models.inference.ai.azure.com"
>>>>>>> 15cceaa55f8a476b7bd8eb690cf3184dab1f7d6b
end
