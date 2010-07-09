module PortfoliosHelper


  def id_to_stock n
     Stock.findById(n) 
  end
end
