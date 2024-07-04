# IaCtest
Technical document:

Segun lo Solicitado el dia del examen, se pidio crear 2 ramas nuevas temporales y luegos hacerles un merge (no recuerdo si delete tambien) 

Se crea la Rama Terraform_final, agregando la carpeta final, con el archivo terraform (dentro del mismo cada instruccion esta comentada) tambien se incluye la "evidencia" del dia del examen que se pudo ingresar a la instancia privada sin problemas (desde la instancia publica). 
![Alt text](https://github.com/andrewsasso/IaCtest/blob/main/final/instacia_privada.jpg "instancia privada")
Una vez creada la rama vuelve al Main (rama principal) y se hizo el merge, la rama ya es segura para ser borrada( pero no recuerdo si mencionaste que la borremos o no, por las dudas la deje)

Luego se crea la Rama Kubernetes_final:

En la misma se agregan los 2 archivos utilizados en el examen, un service y un deploy con el pgadmin. 

se vuelve a hacer el Merge y la rama queda segura para ser eliminada





------
Archivos Raiz son del Primer parcial,


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

1 bucket publico accessible por cualquier subnet y un bucket privado, el bucket privado solo se podra acceder por politica de la subnet privada

----------------

ecr repositorio de contenedores

se crea llamado istea-containers el mismo cuenta con 2 politicas 1 cualquiera puede hacer pull y el otro es para el admin que tiene full access 


