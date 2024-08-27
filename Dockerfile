FROM public.ecr.aws/docker/library/openjdk:11-jre-slim-bullseye
COPY ./target/*.jar /home/app.jar
CMD ["java","-jar","/home/app.jar"]
