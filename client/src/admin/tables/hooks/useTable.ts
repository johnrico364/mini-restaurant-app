import { useQuery } from "@tanstack/react-query";
import axios from "axios";

export const useTables = () => {
  return useQuery({
    queryKey: ["tables"],
    queryFn: async () => {
      const { data } = await axios.get(
        "https://my-json-server.typicode.com/johnrico364/mini-restaurant-app/tables"
      );

      return data;
    },
  });
};
