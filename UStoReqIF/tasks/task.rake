model_to_model :backlogTOreqif do |t|
  t.sources :package    => 'US',
            :model      => 'models/userstory-example.xmi',
            :metamodel  => 'metamodels/UserStory.ecore'
  
  t.targets :package    => 'REQIF',
            :model      => 'models/result-usreqif.xmi',
            :metamodel  => 'metamodels/reqif10.ecore'
  
  t.transformation 'transformations/usTOreqif.rb'
end