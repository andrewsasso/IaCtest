# IaCtest
Technical document:

Primer archivo son las configuraciones de redes  (VPC, Subnets, IG y Nat) 

Vpc_sub_ig_nat.tf

Define region us east 1 
vpc = test vpc 
subnets 2 una publica(my_subnet2_pub) y una privada(my_subnet1_priv)
cuenta con ip elastica para el internet gateway (my_igw)
nat gateway para internet en subnetprivada (test_nat_gateway) 
luego tiene 2 routes para que la subnet publica tenga internet y para que la privada tenga salida a internet

------

Instancias ec2:

Cuenta con 2 instancias 1 en cada subnet.
-------------

Storage (buckets) 

Cuenta con 2 buckets 

1 bucket publico y un bucket privado, el bucket privado solo se podra acceder por politica de la subnet privada

----------------

ecr repositorio de contenedores

se crea llamado istea-containers el mismo cuenta con 2 politicas 1 cualquiera puede hacer pull y el otro es para el admin que tiene full access 


