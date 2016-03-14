Heat do
  Description 'Test'

  Parameter('One') do
    String
    Default 'Test'
    MaxLength 15
  end

  Parameter('Two') do
    String
    Default 'Test'
    MaxLength 15
  end

  Output(:One, FnBase64(Ref('One')))

  Server('MyInstance') do
    flavor 'asdfa'
    image 'asdad'
  end
end
