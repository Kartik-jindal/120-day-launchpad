# We import the tools we need from the SQLAlchemy library.
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import declarative_base

# We create a 'Base' class. Think of this as a central registry
# that keeps track of all the tables we are defining in this file.
# Alembic will look at this Base to know what tables should exist.
Base = declarative_base()

# This Python class represents our 'users' table in the database.
# It inherits from our Base class so it gets registered.
class User(Base):
    # '__tablename__' tells SQLAlchemy the actual name of the table in the database.
    __tablename__ = "users"

    # These class attributes define the columns of our 'users' table.
    # 'id' is an integer, it's the primary key, and it should be indexed for fast lookups.
    id = Column(Integer, primary_key=True, index=True)
    
    # 'email' is a string, it must be unique for each user, and it's also indexed.
    email = Column(String, unique=True, index=True)
    full_name = Column(String)
    