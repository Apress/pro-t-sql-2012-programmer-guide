---------------------------------------------------------------------------------------------
-- Listing 15-20. Creating a Computed Column to Show Hierarchyid Representation in the EDM --
---------------------------------------------------------------------------------------------
ALTER TABLE [HumanResources].[Employee]
ADD OrganizationNodeString AS OrganizationNode.ToString() PERSISTED;
