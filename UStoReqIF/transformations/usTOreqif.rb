phase 'us2reqif' do

STATE = REQIF::DatatypeDefinitionEnumeration.new(
            :identifier => 'STATE',
            :desc => 'STATE',
            :specifiedValues => [REQIF::EnumValue.new(:desc => 'DONE', :identifier =>'DONE'),
                                REQIF::EnumValue.new(:desc => 'INPROGRESS', :identifier =>'INPROGRESS'),
                                REQIF::EnumValue.new(:desc => 'PLANNED', :identifier =>'PLANNED'),
                                REQIF::EnumValue.new(:desc => 'CANCEL', :identifier =>'CANCEL'),
                                ]
            )
            
STRING = REQIF::DatatypeDefinitionString.new(
            :identifier => 'String',
            :desc => 'String',
            :maxLength => 1000
            )
            
STATE_ATT_EP = REQIF::AttributeDefinitionEnumeration.new(
      :desc => 'STATE',
      :identifier => 'STATE',
      :editable => false,
      :multiValued => false,
      :type => STATE 
    )
            
WHO_ATT_EP = REQIF::AttributeDefinitionString.new(
      :desc => 'WHO',
      :identifier => 'WHO',
      :editable => false,
      :type => STRING
    )
    
WHAT_ATT_EP = REQIF::AttributeDefinitionString.new(
      :desc => 'WHAT',
      :identifier => 'WHAT',
      :editable => false,
      :type => STRING
)

WHY_ATT_EP = REQIF::AttributeDefinitionString.new(
      :desc => 'WHY',
      :identifier => 'WHY',
      :editable => false,
      :type => STRING                                
)
 
STATE_ATT_US = REQIF::AttributeDefinitionEnumeration.new(
      :desc => 'STATE',
      :identifier => 'STATE',
      :editable => false,
      :multiValued => false,
      :type => STATE 
    )
            
WHO_ATT_US = REQIF::AttributeDefinitionString.new(
      :desc => 'WHO',
      :identifier => 'WHO',
      :editable => false,
      :type => STRING
    )
    
WHAT_ATT_US = REQIF::AttributeDefinitionString.new(
      :desc => 'WHAT',
      :identifier => 'WHAT',
      :editable => false,
      :type => STRING
)

WHY_ATT_US = REQIF::AttributeDefinitionString.new(
      :desc => 'WHY',
      :identifier => 'WHY',
      :editable => false,
      :type => STRING                                
)                                
                                
EPIC_TYPE = REQIF::SpecificationType.new(
            :identifier => 'Epic',
            :desc => 'Epic',
            :specAttributes => [STATE_ATT_EP, WHO_ATT_EP, WHAT_ATT_EP, WHY_ATT_EP ]
            )

USERSTORY_TYPE = REQIF::SpecObjectType.new(
            :identifier => 'UserStory',
            :desc => 'UserStory',
            :specAttributes => [STATE_ATT_US, WHO_ATT_US, WHAT_ATT_US, WHY_ATT_US ]
            )
            
top_rule 'Backlog2Reqif' do 
	from 	US::ProductBacklog
	to REQIF::ReqIF
	mapping do | backlog , reqif |
    puts 'HEADER'
		reqif.theHeader = backlog.header
    puts 'CONTENT'
		reqif.coreContent=backlog.content
    puts 'END'
	end 
end 

rule 'usheaderTOrheader ' do 
	from US::ProductBacklogHeader
	to REQIF::ReqIFHeader
	mapping do | ush, rh |
		rh.comment = ush.comment
#		rh.creationTime = ush.creationDate
    rh.title = ush.name
    rh.identifier = ush.name 
  end 
end 

rule 'uscontentTOrcontent' do
	from US::ProductBacklogContent
	to REQIF::ReqIFContent
	mapping do | uscont, rcont |		
    rcont.specifications = uscont.elements.select { |epic| epic.kind_of?(US::Epic)}
    rcont.specObjects = uscont.elements.select { |userst| userst.kind_of?(US::UserStory)}
  end
end

rule 'usepicTOrspecifications' do
  from US::Epic
  to REQIF::Specification
  #filter { |bli| puts 'COND1'; bli.kind_of?(US::Epic); puts 'COND2' } 
  mapping do | usepic, rspec |
    puts 'usepicTOrspecifications'
    rspec.identifier = usepic.name
    rspec.desc = usepic.name
    rspec.longName = usepic.name
    rspec.type = EPIC_TYPE
    puts 'whoTOattributevalue2 ::: ' + usepic.state.name
    rspec.values = REQIF::AttributeValueEnumeration.new(
                          :definition => STATE_ATT_EP, 
                          :values => STATE.specifiedValues.find{ |eValue| eValue.identifier = usepic.state.name}) 
    rspec.values = usepic.role
    rspec.values = usepic.goal
    rspec.values = usepic.task
    rspec.children = usepic.userStories
  end 
end

rule 'ususTOrspecobjects' do
  from US::UserStory
  to REQIF::SpecObject
  #filter { |bli| bli.kind_of?(US::UserStory) }
  mapping do |usus, rspecobj |
    puts 'ususTOrspecobjects'
    rspecobj.identifier = usus.name
    rspecobj.desc = usus.name
    rspecobj.longName = usus.name
    rspecobj.type = USERSTORY_TYPE
    rspecobj.values = REQIF::AttributeValueEnumeration.new(
                          :definition => STATE_ATT_US, 
                          :values => STATE.specifiedValues.find{ |eValue| eValue.identifier = usus.state.name}) 
    rspecobj.values = usus.role
    rspecobj.values = usus.goal
    rspecobj.values = usus.task
  end 
end

rule 'ususTOspechierarchy' do
  from US::UserStory
  to REQIF::SpecHierarchy
  mapping do |us, hier|
    puts 'ususTOspechierarchy'
    hier.editable = false
    hier.tableInternal = false
    hier.__container__.__container__.specObjects = us 
#    hier.object = hier.__container__.__container__.specObjects.select{ |sob| sob.identifier = us.name }
#    hier.object = REQIF::ReqIFContent.all_objects.first.specObjects.select{ |sob| sob.identifier = us.name }.first
    #hier.object = us #REFERENCE NOT CONTAINMENT !!! THIS is NOT a solution
  end
end

rule 'whoTOattributevalue' do
  from US::Who
  to REQIF::AttributeValueString
  mapping do |who, att|
    att.definition = WHO_ATT_EP if who.__container__.kind_of?(US::Epic)
    att.definition = WHO_ATT_US if who.__container__.kind_of?(US::UserStory)
    att.theValue = who.name
  end
end

rule 'whatTOattributevalue' do
  from US::What
  to REQIF::AttributeValueString
  mapping do |what, att|
    att.definition = WHAT_ATT_EP if what.__container__.kind_of?(US::Epic)
    att.definition = WHAT_ATT_US if what.__container__.kind_of?(US::UserStory)
    att.theValue = what.name
  end
end

rule 'whyTOattributevalue' do
  from US::Why
  to REQIF::AttributeValueString
  mapping do |why, att|
    att.definition = WHY_ATT_EP if why.__container__.kind_of?(US::Epic)
    att.definition = WHY_ATT_US if why.__container__.kind_of?(US::UserStory)
    att.theValue = why.name
  end
end
#ignore_rule US::UserStory => REQIF::Specification
#ignore_rule US::Epic => REQIF::SpecObject
end

phase 'complete_hierarchy' do

refinement_rule 'ususTOspechierarchy' do
  from US::UserStory
  to REQIF::SpecHierarchy
  mapping do |us, hier|
    puts 'REF_ususTOspechierarchy ' + us.name
    hier.object = REQIF::ReqIFContent.all_objects.first.specObjects.select{ |sob| sob.identifier == us.name }.first
  end
end

end